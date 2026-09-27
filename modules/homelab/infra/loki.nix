{ ... }:
{
  flake.nixosModules.homelab-loki =
    { lib, config, ... }:
    let
      cfg = config.homelab.infra.loki;
      dataDir = config.services.loki.dataDir;
      url = "http://127.0.0.1:3100";
    in
    {
      options.homelab.infra.loki.enable = lib.mkEnableOption "Loki and Alloy journal collection";

      config = lib.mkIf cfg.enable {
        services.loki = {
          enable = true;
          # Start with a fresh store, independent of the retired Loki installation.
          dataDir = "/var/lib/loki-journal";
          configuration = {
            auth_enabled = false;
            server = {
              http_listen_address = "127.0.0.1";
              http_listen_port = 3100;
              grpc_listen_address = "127.0.0.1";
            };
            common = {
              instance_addr = "127.0.0.1";
              path_prefix = dataDir;
              replication_factor = 1;
              ring.kvstore.store = "inmemory";
              storage.filesystem = {
                chunks_directory = "${dataDir}/chunks";
                rules_directory = "${dataDir}/rules";
              };
            };
            schema_config.configs = [
              {
                from = "2026-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
            compactor = {
              working_directory = "${dataDir}/compactor";
              retention_enabled = true;
              delete_request_store = "filesystem";
            };
            limits_config.retention_period = "336h";
            analytics.reporting_enabled = false;
          };
        };

        services.alloy = {
          enable = true;
          extraFlags = [
            "--server.http.listen-addr=127.0.0.1:12345"
            "--storage.path=/var/lib/alloy"
            "--disable-reporting"
          ];
        };
        environment.etc."alloy/config.alloy".text = ''
          loki.relabel "journal" {
            forward_to = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "service_name"
            }
          }

          loki.source.journal "journal" {
            forward_to    = [loki.write.local.receiver]
            relabel_rules = loki.relabel.journal.rules
            labels        = { host = ${builtins.toJSON config.networking.hostName} }
            max_age       = "1h"
          }

          loki.write "local" {
            endpoint {
              url = "${url}/loki/api/v1/push"
            }
            wal {
              enabled = true
            }
          }
        '';

        services.grafana.provision.datasources.settings.datasources = [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            inherit url;
            jsonData.manageAlerts = false;
          }
        ];
      };
    };
}
