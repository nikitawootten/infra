{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  imports = [
    ./observability
  ];

  options.homelab = {
    lan-domain = lib.mkOption {
      type = lib.types.str;
      description = "The base domain of the local network";
      example = "local";
      default = "arpa.nikita.computer";
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
    services.nginx.enable = true;
    # Helper function to create a subdomain for a service
    lib.homelab.mkServiceSubdomain = subdomain: "${subdomain}.${cfg.domain}";
  };
}
