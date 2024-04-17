{ lib, config, ... }:
let cfg = config.homelab.media.radarr;
in {
  options.homelab.media.radarr =
    config.lib.homelab.mkServiceOptionSet "Radarr" "radarr" cfg;

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = config.homelab.media.group;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    homelab.media.homepageConfig.Radarr = {
      priority = lib.mkDefault 4;
      config = {
        description = "Radarr";
        href = "https://${cfg.domain}";
        icon = "radarr.png";
      };
    };
  };
}
