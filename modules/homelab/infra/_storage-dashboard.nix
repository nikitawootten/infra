{
  host,
  expectedPools,
  expectedSmartDisks,
}:
let
  datasource = {
    type = "prometheus";
    uid = "$prometheus";
  };
  selector = ''host="${host}"'';
  alerts = ''ALERTS{${selector},alertname=~"Zfs.*|Disk.*|FilesystemSpaceLow|StorageExporterDown"}'';
  steps = warning: [
    {
      color = "green";
      value = null;
    }
    {
      color = "red";
      value = warning;
    }
  ];
  mapping = values: [
    {
      type = "value";
      options = values;
    }
  ];
  state = text: color: { inherit text color; };
  panel = id: title: type: x: y: w: h: expr: legend: {
    inherit
      id
      title
      type
      datasource
      ;
    gridPos = {
      inherit
        x
        y
        w
        h
        ;
    };
    targets = [
      {
        inherit datasource expr;
        refId = "A";
        legendFormat = legend;
        instant = type != "timeseries";
        range = type == "timeseries";
      }
    ];
    fieldConfig = {
      defaults = {
        noValue = "No data";
        thresholds = {
          mode = "absolute";
          steps = steps 1;
        };
      };
      overrides = [ ];
    };
    options =
      if type == "timeseries" then
        {
          legend = {
            displayMode = "table";
            placement = "bottom";
            calcs = [ "lastNotNull" ];
          };
          tooltip.mode = "multi";
        }
      else
        {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
          colorMode = "background";
          graphMode = "none";
          textMode = "auto";
        };
  };
  stat =
    id: title: x: y: w: expr: legend: values:
    let
      p = panel id title "stat" x y w 4 expr legend;
    in
    p
    // {
      fieldConfig = p.fieldConfig // {
        defaults = p.fieldConfig.defaults // {
          mappings = mapping values;
        };
      };
    };
  graph =
    id: title: x: y: expr: legend: unit: threshold:
    let
      p = panel id title "timeseries" x y 12 12 expr legend;
    in
    p
    // {
      fieldConfig = p.fieldConfig // {
        defaults = p.fieldConfig.defaults // {
          inherit unit;
          min = 0;
          color.mode = "palette-classic";
          thresholds.steps = steps threshold;
          custom = {
            drawStyle = "line";
            lineWidth = 2;
            fillOpacity = 8;
            spanNulls = false;
            thresholdsStyle.mode = "dashed";
          };
        };
      };
    };
  health = mapping {
    "-1" = state "MISSING" "red";
    "0" = state "ONLINE" "green";
    "1" = state "DEGRADED" "orange";
    "2" = state "FAULTED" "red";
    "3" = state "OFFLINE" "red";
    "4" = state "UNAVAILABLE" "red";
    "5" = state "REMOVED" "red";
    "6" = state "SUSPENDED" "red";
  };
  poolCount = builtins.length expectedPools;
  poolPanels = builtins.genList (
    i:
    let
      pool = builtins.elemAt expectedPools i;
      p = panel (100 + i) "${pool} health" "stat" (8 * (i - (i / 3) * 3)) (
        12 + 4 * (i / 3)
      ) 8 4 ''zfs_pool_health{${selector},pool="${pool}"} or on() vector(-1)'' pool;
    in
    p
    // {
      fieldConfig = p.fieldConfig // {
        defaults = p.fieldConfig.defaults // {
          mappings = health;
        };
      };
    }
  ) poolCount;
  detailY = 12 + 4 * ((poolCount + 2) / 3);
in
{
  uid = "storage";
  title = "${host} — Storage health";
  description = "ZFS capacity and health, SMART disk diagnostics, and Prometheus storage alerts.";
  # Resolve the existing source by name instead of changing its persisted UID.
  templating.list = [
    {
      name = "prometheus";
      type = "datasource";
      query = "prometheus";
      regex = "/^Prometheus$/";
      hide = 2;
      refresh = 1;
      multi = false;
      includeAll = false;
      skipUrlSync = true;
    }
  ];
  schemaVersion = 39;
  version = 1;
  editable = false;
  tags = [
    "storage"
    "zfs"
    "smart"
    host
  ];
  timezone = "browser";
  refresh = "1m";
  time = {
    from = "now-24h";
    to = "now";
  };
  panels = [
    (stat 1 "ZFS exporter" 0 0 6 ''up{${selector},job="${host}-zfs"} or on() vector(-1)'' "ZFS" {
      "-1" = state "NO DATA" "red";
      "0" = state "DOWN" "red";
      "1" = state "UP" "green";
    })
    (stat 2 "SMART exporter" 6 0 6 ''up{${selector},job="${host}-smartctl"} or on() vector(-1)'' "SMART"
      {
        "-1" = state "NO DATA" "red";
        "0" = state "DOWN" "red";
        "1" = state "UP" "green";
      }
    )
    (stat 3 "ZFS collection" 12 0 6
      ''zfs_scrape_collector_success{${selector},collector="pool"} or on() vector(-1)''
      "Pool collection"
      {
        "-1" = state "NO DATA" "red";
        "0" = state "FAILED" "red";
        "1" = state "OK" "green";
      }
    )
    (
      let
        p =
          panel 4 "Disks reporting SMART / ${toString expectedSmartDisks} expected" "stat" 18 0 6 4
            "count(smartctl_device_smart_status{${selector}}) or vector(0)"
            "Reporting disks";
      in
      p
      // {
        fieldConfig = p.fieldConfig // {
          defaults = p.fieldConfig.defaults // {
            thresholds.steps = [
              {
                color = "red";
                value = null;
              }
              {
                color = "green";
                value = expectedSmartDisks;
              }
            ];
          };
        };
      }
    )
    (
      let
        p = panel 5 "Active storage alerts" "table" 0 4 24 8 alerts "";
      in
      p
      // {
        description = "Empty means no active storage alerts.";
        targets = [
          {
            inherit datasource;
            refId = "A";
            expr = alerts;
            instant = true;
            format = "table";
          }
        ];
        options = {
          showHeader = true;
          cellHeight = "sm";
        };
        transformations = [
          {
            id = "organize";
            options = {
              excludeByName = {
                Time = true;
                __name__ = true;
                Value = true;
                instance = true;
                job = true;
              };
              renameByName = {
                alertname = "Alert";
                alertstate = "State";
                severity = "Severity";
                pool = "Pool";
                device = "Disk";
                mountpoint = "Mount";
              };
            };
          }
        ];
      }
    )
  ]
  ++ poolPanels
  ++ [
    (graph 10 "ZFS pool utilization — 85% warning" 0 detailY
      "100 * zfs_pool_allocated_bytes{${selector}} / zfs_pool_size_bytes{${selector}}"
      "{{pool}}"
      "percent"
      85
    )
    (graph 11 "Filesystem utilization — 85% warning" 12 detailY
      ''100 * (1 - node_filesystem_avail_bytes{${selector},fstype=~"ext[234]|xfs|btrfs|vfat|exfat|ntfs|f2fs|bcachefs"} / node_filesystem_size_bytes{${selector}}) and (node_filesystem_readonly{${selector}} == 0) and (node_filesystem_size_bytes{${selector}} > 0)''
      "{{mountpoint}} ({{device}})"
      "percent"
      85
    )
    (stat 12 "SMART overall health by disk" 0 (detailY + 12) 12
      "smartctl_device_smart_status{${selector}}"
      "{{device}}"
      {
        "0" = state "FAILED" "red";
        "1" = state "PASSED" "green";
      }
    )
    (stat 13 "SMART collection errors by disk" 12 (detailY + 12) 12
      "smartctl_device_smartctl_exit_status{${selector}} % 8"
      "{{device}}"
      { "0" = state "OK" "green"; }
    )
    (graph 14 "ATA pending / uncorrectable sectors" 0 (detailY + 16)
      ''smartctl_device_attribute{${selector},attribute_value_type="raw",attribute_id=~"197|198"}''
      "{{device}} · {{attribute_name}}"
      "short"
      1
    )
    (graph 15 "ATA reallocated sector change over 1h" 12 (detailY + 16)
      ''delta(smartctl_device_attribute{${selector},attribute_value_type="raw",attribute_id="5"}[1h])''
      "{{device}}"
      "short"
      1
    )
    (graph 16 "SMART self-test error history" 0 (detailY + 28)
      "smartctl_device_self_test_log_error_count{${selector}}"
      "{{device}} · {{self_test_log_type}}"
      "short"
      1
    )
    (
      let
        p = graph 17 "SCSI uncorrected errors (lifetime)" 12 (
          detailY + 28
        ) "smartctl_read_total_uncorrected_errors{${selector}}" "{{device}} · read" "short" 1;
      in
      p
      // {
        targets = p.targets ++ [
          {
            inherit datasource;
            refId = "B";
            expr = "smartctl_write_total_uncorrected_errors{${selector}}";
            legendFormat = "{{device}} · write";
            range = true;
          }
        ];
      }
    )
    (
      let
        p = panel 19 "Disk inventory" "table" 0 (detailY + 40) 24 7 "smartctl_device{${selector}}" "";
      in
      p
      // {
        targets = [
          {
            inherit datasource;
            refId = "A";
            expr = "smartctl_device{${selector}}";
            instant = true;
            format = "table";
          }
        ];
        options = {
          showHeader = true;
          cellHeight = "sm";
        };
        transformations = [
          {
            id = "filterFieldsByName";
            options.include.names = [
              "device"
              "model_name"
              "serial_number"
              "protocol"
            ];
          }
          {
            id = "organize";
            options.renameByName = {
              device = "Disk";
              model_name = "Model";
              serial_number = "Serial number";
              protocol = "Protocol";
            };
          }
        ];
      }
    )
  ];
}
