{ ... }:
{
  flake.nixosModules.homelab-filebrowser =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.media.filebrowser;
      clientId = "filebrowser";
      groupsClaim = "filebrowser_groups";
      userGroup = "filebrowser_users";
      adminGroup = "filebrowser_admins";
      groups = [
        userGroup
        adminGroup
      ];
      mediaRoot = config.homelab.media.mediaRoot;
      serviceUrl = "http://127.0.0.1:8097";
      configFile = (pkgs.formats.yaml { }).generate "filebrowser-quantum.yaml" {
        server = {
          listen = "127.0.0.1";
          port = 8097;
          baseURL = "/";
          externalUrl = cfg.url;
          database = "/var/lib/filebrowser-quantum/database.db";
          cacheDir = "/var/cache/filebrowser-quantum";
          disableUpdateCheck = true;
          sources = [
            {
              path = mediaRoot;
              name = "Media";
              config = {
                defaultEnabled = true;
                defaultUserScope = "/";
                # Prevent public shares, including those created by administrators.
                private = true;
              };
            }
          ];
          filesystem = {
            createFilePermission = "664";
            createDirectoryPermission = "775";
          };
        };
        http.trustedHeaders = [
          "X-Forwarded-Proto"
          "X-Forwarded-Host"
        ];
        auth.methods = {
          noauth = false;
          password = {
            enabled = false;
            signup = false;
          };
          proxy.enabled = false;
          jwt.enabled = false;
          ldap.enabled = false;
          passkey.enabled = false;
          oidc = {
            enabled = true;
            inherit clientId;
            issuerUrl = "https://${config.homelab.infra.kanidm.domain}/oauth2/openid/${clientId}";
            scopes = "openid email profile";
            userIdentifier = "preferred_username";
            inherit groupsClaim;
            inherit adminGroup;
            userGroups = groups;
          };
        };
        userDefaults.account = {
          loginMethod = "oidc";
          permissions = {
            admin = false;
            api = false;
            share = false;
            modify = true;
            create = true;
            delete = true;
            download = true;
          };
        };
        integrations.media.ffmpegPath = "${pkgs.ffmpeg}/bin";
      };
    in
    {
      options.homelab.media.filebrowser =
        config.lib.homelab.mkServiceOptionSet "FileBrowser Quantum" "files" cfg
        // {
          clientSecretFile = lib.mkOption {
            type = lib.types.path;
            description = "File containing the FileBrowser OIDC client secret";
          };
        };

      config = lib.mkIf cfg.enable {
        users.users.filebrowser-quantum = {
          isSystemUser = true;
          group = config.homelab.media.group;
        };
        systemd.services.filebrowser-quantum = {
          description = "FileBrowser Quantum";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [
            "network-online.target"
            "kanidm.service"
            "nginx.service"
          ];
          unitConfig.RequiresMountsFor = [ mediaRoot ];
          script = ''
            export FILEBROWSER_OIDC_CLIENT_SECRET="$(cat "$CREDENTIALS_DIRECTORY/client-secret")"
            exec ${lib.getExe pkgs.filebrowser-quantum} -c ${configFile}
          '';
          serviceConfig = {
            User = "filebrowser-quantum";
            Group = config.homelab.media.group;
            LoadCredential = "client-secret:${cfg.clientSecretFile}";
            StateDirectory = "filebrowser-quantum";
            StateDirectoryMode = "0700";
            CacheDirectory = "filebrowser-quantum";
            CacheDirectoryMode = "0700";
            WorkingDirectory = "/var/lib/filebrowser-quantum";
            UMask = "0002";
            Restart = "on-failure";
            RestartSec = 5;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ mediaRoot ];
            PrivateTmp = true;
            PrivateDevices = true;
            NoNewPrivileges = true;
          };
        };
        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          useACMEHost = config.homelab.domain;
          locations."/" = {
            proxyPass = serviceUrl;
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = ''
              client_max_body_size 0;
              proxy_request_buffering off;
              proxy_read_timeout 600s;
              proxy_set_header X-Forwarded-Host $host;
            '';
          };
        };
        services.kanidm.provision = {
          groups = lib.genAttrs groups (_: {
            overwriteMembers = false;
          });
          systems.oauth2.${clientId} = {
            displayName = cfg.name;
            originUrl = [ "${cfg.url}/api/auth/oidc/callback" ];
            originLanding = cfg.url;
            preferShortUsername = true;
            basicSecretFile = cfg.clientSecretFile;
            # Quantum 1.5.2 uses the authorization code flow without PKCE.
            allowInsecureClientDisablePkce = true;
            scopeMaps = lib.genAttrs groups (_: [
              "openid"
              "email"
              "profile"
            ]);
            claimMaps.${groupsClaim} = {
              joinType = "array";
              valuesByGroup = lib.genAttrs groups (group: [ group ]);
            };
          };
        };
        homelab.media.managementHomepageConfig.${cfg.name} = {
          priority = lib.mkDefault 1;
          config = {
            description = "Media file manager";
            href = cfg.url;
            icon = "filebrowser.png";
            siteMonitor = serviceUrl;
          };
        };
      };
    };
}
