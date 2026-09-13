{ ... }:
{
  flake.nixosModules.homelab-prowlarr =
    { lib, config, ... }:
    let
      cfg = config.homelab.media.prowlarr;
      kanidmGroup = "prowlarr_users";
      serviceUrl = "http://127.0.0.1:9696";
    in
    {
      options.homelab.media.prowlarr = config.lib.homelab.mkServiceOptionSet "Prowlarr" "prowlarr" cfg;

      config = lib.mkIf cfg.enable {
        services.prowlarr = {
          enable = true;
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
          priority = lib.mkDefault 5;
          config = {
            description = "Indexer manager";
            href = cfg.url;
            icon = "prowlarr.png";
            siteMonitor = serviceUrl;
            widget = {
              type = "prowlarr";
              url = serviceUrl;
              key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
            };
          };
        };
      };
    };
}
