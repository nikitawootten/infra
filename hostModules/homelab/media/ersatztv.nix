{ lib, config, ... }:
let
  cfg = config.homelab.media.ersatztv;
  kanidmGroup = "ersatztv_users";
in {
  options.homelab.media.ersatztv =
    (config.lib.homelab.mkServiceOptionSet "ErsatzTV" "ersatztv" cfg) // {
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.homelab.media.configRoot}/ersatztv";
        description = "Directory to store ErsatzTV configuration";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 8409;
        description = "Port to expose ErsatzTV on";
      };
      streamingPort = lib.mkOption {
        type = lib.types.int;
        default = 8410;
        description = "Port for streaming (internal use)";
      };
    };

  config = lib.mkIf cfg.enable {
    services.ersatztv = {
      enable = true;
      group = config.homelab.media.group;
      environment = {
        ETV_UI_PORT = cfg.port;
        ETV_STREAMING_PORT = cfg.streamingPort;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        recommendedProxySettings = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.streamingPort ];

    services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
      allowed_groups = [ kanidmGroup ];
    };
    homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

    homelab.media.managementHomepageConfig.${cfg.name} = {
      priority = lib.mkDefault 5;
      config = {
        description = "Manage custom IPTV steams";
        href = cfg.url;
        icon = "ersatztv.png";
        siteMonitor = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
