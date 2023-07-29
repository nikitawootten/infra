{ config, secrets, ... }: {
  # TODO not working for now, Docker and SystemD don't play well

  age.secrets.openldap.file = secrets.openldap;

  virtualisation.arion.projects.lab.settings.services.openldap = { pkgs, ... }: {
    nixos = {
      useSystemd = true;

      configuration = {
        boot.tmp.useTmpfs = true;
        system.stateVersion = "23.11";

        users.users.openldap = {
          isNormalUser = false;
          uid = 1000;
        };
        users.groups.openldap.gid = 1000;

        services.openldap = {
          enable = true;
          urlList = [ "ldap:///" ];
          settings = {
            attrs = {
              olcLogLevel = "conns config";
            };
            children = {
              "cn=schema".includes = [
                "${pkgs.openldap}/etc/schema/core.ldif"
                "${pkgs.openldap}/etc/schema/cosine.ldif"
                "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
              ];

              "olcDatabase={1}mdb".attrs = {
                objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap/data";

                olcSuffix = "dc=example,dc=com";

                olcRootDN = "cn=admin,dc=example,dc=com";
                olcRootPW.path = "/var/lib/openldap/rootpwd";

                olcAccess = [
                  /* custom access rules for userPassword attributes */
                  ''{0}to attrs=userPassword
                      by self write
                      by anonymous auth
                      by * none''

                  /* allow read on anything else */
                  ''{1}to *
                      by * read''
                ];
              };
            };
          };
        };
      };
    };

    service = {
      container_name = "openldap";
      volumes = [
        "${config.lib.lab.mkConfigDir "openldap"}/:/var/lib/openldap/ldap"
        "${config.age.secrets.openldap.path}:/var/lib/openldap/rootpwd"
      ];
      useHostStore = true;
    };
  };
}