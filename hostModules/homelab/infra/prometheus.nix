{ lib, config, ... }:
let cfg = config.homelab.infra.prometheus;
in {
  options.homelab.infra.prometheus = {
    enable = lib.mkEnableOption "Prometheus";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      exporters = {
        node = {
          port = 9002;
          enabledCollectors = [ "systemd" "processes" ];
          enable = true;
        };
      };

      scrapeConfigs = [{
        job_name = config.networking.hostName;
        static_configs = [{
          targets = [
            "127.0.0.1:${
              toString config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }];
    };

    services.grafana.provision.datasources.settings.datasources = [{
      name = "Prometheus";
      type = "prometheus";
      access = "proxy";
      url = "http://127.0.0.1:${toString config.services.prometheus.port}";
    }];
  };
}
