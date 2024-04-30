{ lib, config, ... }:
let cfg = config.homelab.media.jellyseerr;
in {
  options.homelab.media.jellyseerr =
    config.lib.homelab.mkServiceOptionSet "Jellyseerr" "jellyseerr" cfg;

  config = lib.mkIf cfg.enable {
    services.jellyseerr = { enable = true; };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass =
          "http://127.0.0.1:${toString config.services.jellyseerr.port}";
        recommendedProxySettings = true;
      };
    };

    homelab.media.homepageConfig.Jellyseerr = {
      priority = lib.mkDefault 1;
      config = {
        description = "Jellyseerr";
        href = "https://${cfg.domain}";
        icon = "jellyseerr.png";
      };
    };

    topology.self.services.jellyseerr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
