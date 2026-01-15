{ lib, config, ... }:
let
  cfg = config.homelab.acme;
in
{
  options.homelab.acme = {
    email = lib.mkOption {
      type = lib.types.str;
      description = "The email address to use for ACME registration";
    };
    dnsProvider = lib.mkOption {
      type = lib.types.str;
      description = "The DNS provider to use for ACME DNS-01 challenges";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
      description = "The file to use for storing ACME credentials";
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = cfg.email;
        credentialsFile = cfg.credentialsFile;
        dnsProvider = cfg.dnsProvider;
      };

      certs.${config.homelab.domain} = {
        extraDomainNames = [ "*.${config.homelab.domain}" ];
      };
    };

    users.groups.acme.members = [ config.services.nginx.user ];
  };
}
