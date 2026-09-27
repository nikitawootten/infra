{ ... }:
{
  flake.nixosModules.homelab-prometheus =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.infra.prometheus;
    in
    {
      options.homelab.infra.prometheus = {
        enable = lib.mkEnableOption "Prometheus";
        expectedPools = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "ZFS pools whose health metrics must always be present.";
        };
        expectedSmartDisks = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 0;
          description = "Minimum number of disks reporting SMART health, including spares.";
        };
        discordWebhookFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Runtime file containing the Discord webhook URL; null disables delivery.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.prometheus = {
          enable = true;

          rules = [
            (builtins.toJSON {
              groups = [
                {
                  name = "storage";
                  rules = [
                    {
                      alert = "ZfsPoolUnhealthy";
                      expr = "zfs_pool_health != 0";
                      for = "2m";
                      labels.severity = "critical";
                      annotations = {
                        summary = "{{ $labels.host }}: ZFS pool {{ $labels.pool }} is unhealthy";
                        description = "Pool health code {{ $value }} (0 ONLINE, 1 DEGRADED, 2 FAULTED, 3 OFFLINE, 4 UNAVAIL, 5 REMOVED, 6 SUSPENDED). Run zpool status -v.";
                      };
                    }
                    {
                      alert = "ZfsCollectionFailed";
                      expr = "zfs_scrape_collector_success{collector=\"pool\"} != 1";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: ZFS pool collection failed";
                        description = "The exporter is serving HTTP but cannot collect pool data. Check its logs; cached health values may be stale.";
                      };
                    }
                    {
                      alert = "DiskScsiUncorrectedErrors";
                      expr = "smartctl_read_total_uncorrected_errors > 0 or smartctl_write_total_uncorrected_errors > 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: disk {{ $labels.device }} has uncorrected SCSI errors";
                        description = "The disk reports uncorrected read or write errors. Counts may be historical; inspect smartctl -x and verify backups.";
                      };
                    }
                    {
                      alert = "DiskSmartFailed";
                      expr = "smartctl_device_smart_status == 0";
                      for = "2m";
                      labels.severity = "critical";
                      annotations = {
                        summary = "{{ $labels.host }}: disk {{ $labels.device }} failed SMART";
                        description = "SMART overall health reports failure. Inspect smartctl -x for this disk and prepare replacement.";
                      };
                    }
                    {
                      alert = "DiskBadSectors";
                      expr = "smartctl_device_attribute{attribute_value_type=\"raw\",attribute_id=~\"197|198\"} > 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: disk {{ $labels.device }} has bad sectors";
                        description = "{{ $labels.attribute_name }} (SMART {{ $labels.attribute_id }}) reports {{ $value }} sectors. Inspect smartctl -x and backups.";
                      };
                    }
                    {
                      alert = "DiskReallocatedSectorsIncreasing";
                      expr = "delta(smartctl_device_attribute{attribute_value_type=\"raw\",attribute_id=\"5\"}[1h]) > 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: disk {{ $labels.device }} is reallocating sectors";
                        description = "Reallocated sector count increased over the last hour. Inspect smartctl -x and plan replacement if deterioration continues.";
                      };
                    }
                    {
                      alert = "DiskSelfTestErrors";
                      expr = "smartctl_device_self_test_log_error_count > 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: disk {{ $labels.device }} has SMART self-test errors";
                        description = "The {{ $labels.self_test_log_type }} self-test log contains {{ $value }} errors. These may be historical; inspect smartctl -l selftest.";
                      };
                    }
                    {
                      alert = "DiskSmartCollectionFailed";
                      expr = "smartctl_device_smartctl_exit_status % 8 != 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: cannot reliably read SMART for {{ $labels.device }}";
                        description = "smartctl reports command, device-open, or SMART-command errors. Check exporter permissions and controller support.";
                      };
                    }
                    {
                      alert = "StorageExporterDown";
                      expr = "up{job=~\"${config.networking.hostName}-(zfs|smartctl)\"} == 0";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: storage exporter {{ $labels.job }} is unavailable";
                        description = "Storage health alerts depend on this exporter. Check its systemd service and logs.";
                      };
                    }

                    {
                      alert = "ZfsPoolSpaceLow";
                      expr = "100 * zfs_pool_allocated_bytes / zfs_pool_size_bytes >= 85";
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: ZFS pool {{ $labels.pool }} is nearly full";
                        description = "Pool utilization is {{ printf \"%.1f\" $value }}%.";
                      };
                    }
                    {
                      alert = "FilesystemSpaceLow";
                      expr = ''
                        (100 * (1 - node_filesystem_avail_bytes{fstype=~"ext[234]|xfs|btrfs|vfat|exfat|ntfs|f2fs|bcachefs"}
                          / node_filesystem_size_bytes) >= 85)
                        and (node_filesystem_readonly == 0)
                        and (node_filesystem_size_bytes > 0)
                      '';
                      for = "5m";
                      labels.severity = "warning";
                      annotations = {
                        summary = "{{ $labels.host }}: {{ $labels.mountpoint }} is nearly full";
                        description = "Filesystem {{ $labels.device }} utilization is {{ printf \"%.1f\" $value }}%.";
                      };
                    }
                  ]
                  ++ map (pool: {
                    alert = "ZfsPoolMissing";
                    expr = "absent(zfs_pool_health{host=${builtins.toJSON config.networking.hostName},pool=${builtins.toJSON pool}})";
                    for = "5m";
                    labels = {
                      severity = "critical";
                      host = config.networking.hostName;
                      inherit pool;
                    };
                    annotations = {
                      summary = "{{ $labels.host }}: expected ZFS pool {{ $labels.pool }} is missing";
                      description = "No health metric for this pool. Check zpool status and the ZFS exporter.";
                    };
                  }) cfg.expectedPools
                  ++ lib.optional (cfg.expectedSmartDisks > 0) {
                    alert = "DiskSmartCoverageMissing";
                    expr = "(count(smartctl_device_smart_status{host=${builtins.toJSON config.networking.hostName}}) or vector(0)) < ${toString cfg.expectedSmartDisks}";
                    for = "5m";
                    labels = {
                      severity = "warning";
                      host = config.networking.hostName;
                    };
                    annotations = {
                      summary = "{{ $labels.host }}: SMART disk coverage is incomplete";
                      description = "Only {{ $value }} disks report SMART health; expected at least ${toString cfg.expectedSmartDisks}, including spares. Check discovery, permissions, and missing drives.";
                    };
                  };
                }
              ];
            })
          ];

          alertmanagers = lib.optional (cfg.discordWebhookFile != null) {
            static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ];
          };
          alertmanager = lib.mkIf (cfg.discordWebhookFile != null) {
            enable = true;
            listenAddress = "127.0.0.1";
            extraFlags = [ "--cluster.listen-address=" ];
            configuration = {
              route = {
                receiver = "discord";
                group_by = [
                  "alertname"
                  "host"
                  "pool"
                  "mountpoint"
                  "device"
                ];
                group_wait = "30s";
                group_interval = "5m";
                repeat_interval = "12h";
              };
              receivers = [
                {
                  name = "discord";
                  discord_configs = [
                    {
                      webhook_url_file = "/run/credentials/alertmanager.service/discord-webhook";
                      send_resolved = true;
                      title = "[{{ .Status }}] {{ .CommonLabels.alertname }} on {{ .CommonLabels.host }}";
                      message = "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n{{ end }}";
                    }
                  ];
                }
              ];
            };
          };

          exporters = {
            smartctl = {
              enable = true;
              listenAddress = "127.0.0.1";
            };
            zfs = {
              enable = true;
              listenAddress = "127.0.0.1";
              extraFlags = [
                "--no-collector.dataset-filesystem"
                "--no-collector.dataset-volume"
              ];
            };
            node = {
              port = 9002;
              enabledCollectors = [
                "systemd"
                "processes"
              ];
              enable = true;
            };
          };

          scrapeConfigs = [
            {
              job_name = "${config.networking.hostName}-smartctl";
              static_configs = [
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ];
                  labels.host = config.networking.hostName;
                }
              ];
            }
            {
              job_name = "${config.networking.hostName}-zfs";
              static_configs = [
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}" ];
                  labels.host = config.networking.hostName;
                }
              ];
            }
            {
              job_name = config.networking.hostName;
              static_configs = [
                {
                  labels.host = config.networking.hostName;
                  targets = [
                    "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
                  ];
                }
              ];
            }
          ];
        };

        homelab.infra.homepageConfig."Prometheus" = {
          priority = lib.mkDefault 6;
          config = {
            description = "Metrics and alert monitoring";
            icon = "prometheus.png";
            widget = {
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              fields = [
                "targets_up"
                "targets_down"
                "targets_total"
              ];
            };
          };
        };

        systemd.services.alertmanager = lib.mkIf (cfg.discordWebhookFile != null) {
          serviceConfig.LoadCredential = [ "discord-webhook:${cfg.discordWebhookFile}" ];
        };

        services.grafana.provision.dashboards.settings.providers = [
          {
            name = "storage";
            folder = "Infrastructure";
            type = "file";
            allowUiUpdates = false;
            options.path = pkgs.writeTextDir "storage.json" (
              builtins.toJSON (
                import ./_storage-dashboard.nix {
                  host = config.networking.hostName;
                  inherit (cfg) expectedPools expectedSmartDisks;
                }
              )
            );
          }
        ];

        services.grafana.provision.datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
}
