{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  imports = [
    ./auth
    ./media
    ./observability
    ./acme.nix
    ./homepage.nix
    ./vpn.nix
  ];

  options.homelab = {
    lan-domain = lib.mkOption {
      type = lib.types.str;
      description = "The base domain of the local network";
      example = "your-domain.com";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain all services will be deployed under";
      default = "${config.networking.hostName}.${cfg.lan-domain}";
      readOnly = true;
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
    };

    # Helper function to create a subdomain for a service
    lib.homelab.mkServiceSubdomain = subdomain: "${subdomain}.${cfg.domain}";

    lib.homelab.mkServiceOptionSet = name: subdomain: cfg: {
      enable = lib.mkEnableOption name;
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = subdomain;
        description = "${name}'s subdomain";
      };
      domain = lib.mkOption {
        type = lib.types.str;
        default = config.lib.homelab.mkServiceSubdomain cfg.subdomain;
        description = "${name}'s domain";
        readOnly = true;
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = "https://${cfg.domain}";
        description = "${name}'s URL";
        readOnly = true;
      };
    };
  };
}
