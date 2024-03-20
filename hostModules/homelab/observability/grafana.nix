{ lib, config, ... }:
let
  cfg = config.homelab.observability.grafana;
in
{
  options.homelab.observability.grafana = {
    enable = lib.mkEnableOption "Grafana";
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "grafana";
      description = "Grafana's subdomain";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.lib.homelab.mkServiceSubdomain cfg.subdomain;
      description = "Grafana's domain";
      readOnly = true;
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://${cfg.domain}";
      description = "Grafana's URL";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server.domain = lib.mkForce cfg.domain;
      provision = {
        enable = true;
        datasources.settings.apiVersion = 1;
      };
    };

    services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
          proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
      };
    };
  };
}
