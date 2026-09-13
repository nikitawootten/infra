{ ... }:
{
  flake.nixosModules.homelab-radarr =
    { lib, config, ... }:
    let
      cfg = config.homelab.media.radarr;
      kanidmGroup = "radarr_users";
      serviceUrl = "http://127.0.0.1:7878";
    in
    {
      options.homelab.media.radarr = config.lib.homelab.mkServiceOptionSet "Radarr" "radarr" cfg;

      config = lib.mkIf cfg.enable {
        services.radarr = {
          enable = true;
          group = config.homelab.media.group;
          settings.auth.method = "External";
        };

        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          useACMEHost = config.homelab.domain;
          locations."/" = {
            proxyPass = serviceUrl;
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
        services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
          allowed_groups = [ kanidmGroup ];
        };
        homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

        homelab.media.managementHomepageConfig.${cfg.name} = {
          priority = lib.mkDefault 4;
          config = {
            description = "Movie download manager";
            href = cfg.url;
            icon = "radarr.png";
            siteMonitor = serviceUrl;
            widget = {
              type = "radarr";
              url = serviceUrl;
              key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
            };
          };
        };
      };
    };
}
