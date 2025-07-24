{ pkgs, lib, config, ... }:
let
  cfg = config.homelab.auth.kanidm;
  inherit (config.security.acme.certs.${config.homelab.domain}) directory;
in {
  options.homelab.auth.kanidm =
    (config.lib.homelab.mkServiceOptionSet "Kanidm" "idp" cfg) // {
      adminPasswordFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the Kanidm admin password";
      };
    };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 636 ];

    services.kanidm = {
      package = pkgs.kanidm.override { enableSecretProvisioning = true; };

      enableClient = true;
      clientSettings.uri = config.services.kanidm.serverSettings.origin;

      enableServer = true;
      serverSettings = {
        domain = config.homelab.lan-domain;
        origin = cfg.url;
        ldapbindaddress = "0.0.0.0:636";
        bindaddress = "0.0.0.0:8443";
        tls_key = "${directory}/key.pem";
        tls_chain = "${directory}/fullchain.pem";
      };

      provision = {
        enable = true;
        adminPasswordFile = cfg.adminPasswordFile;
        idmAdminPasswordFile = cfg.adminPasswordFile;
        persons.nikita = {
          displayName = "Nikita";
          legalName = "Nikita";
          mailAddresses = [ "me@nikita.computer" ];
          groups = lib.attrNames config.services.kanidm.provision.groups;
        };
      };
    };

    users.groups.acme.members = [ "kanidm" ];

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = config.services.kanidm.provision.instanceUrl;
        recommendedProxySettings = true;
      };
    };

    homelab.auth.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 1;
      config = {
        description = "SSO and identity provider";
        href = cfg.url;
        icon = "kanidm.png";
        siteMonitor = cfg.url;
      };
    };
  };
}
