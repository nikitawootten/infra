{ lib, config, ... }:
let
  cfg = config.homelab.observability.grafana;
in
{
  options.homelab.observability.grafana = config.lib.homelab.mkServiceOptionSet "Grafana" "grafana" cfg;

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

    homelab.observability.homepageConfig.Grafana = {
      priority = lib.mkDefault 1;
      config = {
        description = "Grafana";
        href = "https://${cfg.domain}";
        icon = "grafana.png";
      };
    };
  };
}
