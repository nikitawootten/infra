{ lib, config, ... }:
let
  cfg = config.homelab.homepage;
in
{
  options.homelab.homepage = {
    enable = lib.mkEnableOption "Homepage dashboard";
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.domain;
      description = "Homepage domain";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/".proxyPass = "http://localhost:${toString config.services.homepage-dashboard.listenPort}";
    };
  };
}
