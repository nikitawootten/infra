{ config, ... }:
let
  MANAGE_HTTP_PORT = 8088;
  MANAGE_HTTPS_PORT = 8043;
  PORTAL_HTTP_PORT = 8088;
  PORTAL_HTTPS_PORT = 8843;
  PORT_APP_DISCOVERY = 27001;
  PORT_ADOPT_V1 = 29812;
  PORT_UPGRADE_V1 = 29813;
  PORT_MANAGER_V1 = 29811;
  PORT_MANAGER_V2 = 29814;
  PORT_DISCOVERY = 29810;
  PORT_TRANSFER_V2 = 29815;
  PORT_RTTY = 29816;

  name = "omada-controller";
  subdomain = "omada";
  fqdn = "${config.lib.lab.mkServiceSubdomain subdomain}";
in
{
  virtualisation.arion.projects.lab.settings.services.omada-controller = {
    service = {
      container_name = name;
      image = "mbentley/omada-controller:5.12";
      environment = {
        TZ = "America/New_York";
        PUID = "1000";
        PGID = "1000";
        MANAGE_HTTP_PORT = builtins.toString MANAGE_HTTP_PORT;
        MANAGE_HTTPS_PORT = builtins.toString MANAGE_HTTPS_PORT;
        PORTAL_HTTP_PORT = builtins.toString PORTAL_HTTP_PORT;
        PORTAL_HTTPS_PORT = builtins.toString PORTAL_HTTPS_PORT;
        PORT_APP_DISCOVERY = builtins.toString PORT_APP_DISCOVERY;
        PORT_ADOPT_V1 = builtins.toString PORT_ADOPT_V1;
        PORT_UPGRADE_V1 = builtins.toString PORT_UPGRADE_V1;
        PORT_MANAGER_V1 = builtins.toString PORT_MANAGER_V1;
        PORT_MANAGER_V2 = builtins.toString PORT_MANAGER_V2;
        PORT_DISCOVERY = builtins.toString PORT_DISCOVERY;
        PORT_TRANSFER_V2 = builtins.toString PORT_TRANSFER_V2;
        PORT_RTTY = builtins.toString PORT_RTTY;
        SHOW_SERVER_LOGS = "true";
      };
      ports = [
        "${builtins.toString MANAGE_HTTP_PORT}:${builtins.toString MANAGE_HTTP_PORT}"
        "${builtins.toString MANAGE_HTTPS_PORT}:${builtins.toString MANAGE_HTTPS_PORT}"
        "${builtins.toString PORTAL_HTTPS_PORT}:${builtins.toString PORTAL_HTTPS_PORT}"
        "${builtins.toString PORT_APP_DISCOVERY}:${builtins.toString PORT_APP_DISCOVERY}/udp"
        "${builtins.toString PORT_DISCOVERY}:${builtins.toString PORT_DISCOVERY}/udp"
        "${builtins.toString PORT_MANAGER_V1}-${builtins.toString PORT_RTTY}:${builtins.toString PORT_MANAGER_V1}-${builtins.toString PORT_RTTY}"
      ];
      volumes = [
        "${config.lib.lab.mkConfigDir name}/:/opt/tplink/EAPController/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        inherit name subdomain;
        port = builtins.toString MANAGE_HTTPS_PORT;
        scheme = "https";
        middleware = "mid-omada-headers,mid-omada-redirectRegex";
      } // {
        "traefik.http.middlewares.mid-omada-headers.headers.customRequestHeaders.host" = "${fqdn}:${builtins.toString MANAGE_HTTPS_PORT}";
        "traefik.http.middlewares.mid-omada-headers.headers.customResponseHeaders.host" = fqdn;
        "traefik.http.middlewares.mid-omada-redirectRegex.redirectRegex.regex" = "^https:\\/\\/([^\\/]+)\\/?$";
        "traefik.http.middlewares.mid-omada-redirectRegex.redirectRegex.replacement" = "https://$1/controller_id/login";
        "traefik.http.services.omada-controller.loadbalancer.passhostheader" = "true";
      } // config.lib.lab.mkHomepageLabels {
        name = "Omada Controller";
        description = "TPLink SDN Controller";
        group = "Infrastructure";
        inherit subdomain;
        icon = "omada.png";
      };
      restart = "unless-stopped";
    };
  };

  # TPLink Omada Controller requires a myriad of ports
  networking.firewall = {
    allowedTCPPorts = [
      PORT_ADOPT_V1
      PORTAL_HTTPS_PORT
    ];
    allowedTCPPortRanges = [
      {
        from = PORT_MANAGER_V1;
        to = PORT_RTTY;
      }
    ];
    allowedUDPPorts = [
      PORT_APP_DISCOVERY
      PORT_DISCOVERY
    ];
  };
}
