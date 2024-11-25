{ lib, config, ... }:
let cfg = config.services.omada-controller;
in {
  options.services.omada-controller = {
    enable = lib.mkEnableOption "Omada Controller";
    image = lib.mkOption {
      type = lib.types.str;
      default = "mbentley/omada-controller:latest";
      description = "Docker image to use";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8409;
      description = "Port to expose Omada controller on";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "omada";
      description = "User to run the omada controller as";
    };
    uid = lib.mkOption {
      type = lib.types.int;
      default = 508;
      description = "User ID to run the omada controller as";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "omada";
      description = "Group to run the omada controller as";
    };
    gid = lib.mkOption {
      type = lib.types.int;
      default = 508;
      description = "Group ID to run the omada controller as";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall for the omada controller";
    };
    portManageHTTP = lib.mkOption {
      type = lib.types.int;
      default = 8008;
    };
    portManageHTTPS = lib.mkOption {
      type = lib.types.int;
      default = 8043;
    };
    portPortalHTTP = lib.mkOption {
      type = lib.types.int;
      default = 8088;
    };
    portPortalHTTPS = lib.mkOption {
      type = lib.types.int;
      default = 8843;
    };
    portAppDiscovery = lib.mkOption {
      type = lib.types.int;
      default = 27001;
    };
    portDiscovery = lib.mkOption {
      type = lib.types.int;
      default = 29810;
    };
    portManagerV1 = lib.mkOption {
      type = lib.types.int;
      default = 29811;
    };
    portAdoptV1 = lib.mkOption {
      type = lib.types.int;
      default = 29812;
    };
    portUpgradeV1 = lib.mkOption {
      type = lib.types.int;
      default = 29813;
    };
    portManagerV2 = lib.mkOption {
      type = lib.types.int;
      default = 29814;
    };
    portTransferV2 = lib.mkOption {
      type = lib.types.int;
      default = 29815;
    };
    portRTTY = lib.mkOption {
      type = lib.types.int;
      default = 29816;
    };
  };

  config = let
    portManageHTTP = toString cfg.portManageHTTP;
    portManageHTTPS = toString cfg.portManageHTTPS;
    portPortalHTTP = toString cfg.portPortalHTTP;
    portPortalHTTPS = toString cfg.portPortalHTTPS;
    portAdoptV1 = toString cfg.portAdoptV1;
    portAppDiscovery = toString cfg.portAppDiscovery;
    portDiscovery = toString cfg.portDiscovery;
    portManagerV1 = toString cfg.portManagerV1;
    portManagerV2 = toString cfg.portManagerV2;
    portTransferV2 = toString cfg.portTransferV2;
    portRTTY = toString cfg.portRTTY;
    portUpgradeV1 = toString cfg.portUpgradeV1;
  in lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      uid = cfg.uid;
      group = cfg.group;
    };
    users.groups.${cfg.group} = { gid = cfg.gid; };

    # Patch service configuration to add required directories
    systemd.services."${config.virtualisation.oci-containers.backend}-omada-controller" =
      {
        serviceConfig = {
          StateDirectory = "omada-controller";
          LogsDirectory = "omada-controller";
        };
      };

    virtualisation.oci-containers.containers.omada-controller = {
      image = cfg.image;
      environment = {
        TZ = config.time.timeZone;
        PUID = toString cfg.uid;
        PGID = toString cfg.gid;
        MANAGE_HTTP_PORT = portManageHTTP;
        MANAGE_HTTPS_PORT = portManageHTTPS;
        PORTAL_HTTP_PORT = portPortalHTTP;
        PORTAL_HTTPS_PORT = portPortalHTTPS;
        PORT_ADOPT_V1 = portAdoptV1;
        PORT_APP_DISCOVERY = portAppDiscovery;
        PORT_DISCOVERY = portDiscovery;
        PORT_MANAGER_V1 = portManagerV1;
        PORT_MANAGER_V2 = portManagerV2;
        PORT_TRANSFER_V2 = portTransferV2;
        PORT_RTTY = portRTTY;
        PORT_UPGRADE_V1 = portUpgradeV1;
      };
      ports = [
        "${portManageHTTP}:${portManageHTTP}"
        "${portManageHTTPS}:${portManageHTTPS}"
        "${portPortalHTTPS}:${portPortalHTTPS}"
        "${portAppDiscovery}:${portAppDiscovery}/udp"
        "${portDiscovery}:${portDiscovery}/udp"
        "${portManagerV1}:${portManagerV1}"
        "${portAdoptV1}:${portAdoptV1}"
        "${portUpgradeV1}:${portUpgradeV1}"
        "${portManagerV2}:${portManagerV2}"
        "${portTransferV2}:${portTransferV2}"
        "${portRTTY}:${portRTTY}"
      ];
      volumes = [
        "/var/lib/omada-controller:/opt/tplink/EAPController/data"
        "/var/log/omada-controller:/opt/tplink/EAPController/logs"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      cfg.portManagerV1
      cfg.portAdoptV1
      cfg.portUpgradeV1
      cfg.portManagerV2
      cfg.portTransferV2
      cfg.portRTTY
    ];
    networking.firewall.allowedUDPPorts =
      [ cfg.portAppDiscovery cfg.portDiscovery ];
  };
}
