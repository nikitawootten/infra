{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.grafana = {
    service = {
      container_name = "grafana";
      image = "grafana/grafana-enterprise";
      environment = {
        GF_INSTALL_PLUGINS = "grafana-clock-panel";
      };
      ports = [ "3003:3000" ];
      volumes = [
        "/etc/grafana/grafana.ini"
        "${config.lib.lab.mkConfigDir "grafana"}/:/var/lib/grafana"
      ];
    };
  };
}