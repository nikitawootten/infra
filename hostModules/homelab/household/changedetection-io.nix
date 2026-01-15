{ config, lib, ... }:
let
  cfg = config.homelab.household.changedetection-io;
  kanidmGroup = "changedetectionio_users";
  serviceUrl = "http://127.0.0.1:${toString config.services.changedetection-io.port}";
in
{
  options.homelab.household.changedetection-io =
    config.lib.homelab.mkServiceOptionSet "ChangeDetection.io" "change" cfg // { };

  config = lib.mkIf cfg.enable {
    services.changedetection-io = {
      enable = true;
      behindProxy = true;
      baseURL = cfg.url;
      playwrightSupport = true;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = serviceUrl;
        recommendedProxySettings = true;
      };
    };
    services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
      allowed_groups = [ kanidmGroup ];
    };
    homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

    homelab.household.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 11;
      config = {
        description = "Web monitoring service";
        href = cfg.url;
        icon = "changedetection.png";
        siteMonitor = cfg.url;
        widget = {
          type = "changedetectionio";
          url = serviceUrl;
          key = "{{HOMEPAGE_VAR_CHANGEDETECTIONIO_API_KEY}}";
        };
      };
    };
  };
}
