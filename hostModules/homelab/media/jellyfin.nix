{ lib, config, ... }:
let
  cfg = config.homelab.media.jellyfin;
in
{
  options.homelab.media.jellyfin = config.lib.homelab.mkServiceOptionSet "Jellyfin" "jellyfin" cfg;

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = config.homelab.media.group;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    networking.firewall.allowedUDPPorts = [
      1900
      7359
    ];

    homelab.media.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 6;
      config = {
        description = "TV show and movie server";
        href = cfg.url;
        icon = "jellyfin.png";
        siteMonitor = cfg.url;
        widget = {
          type = "jellyfin";
          url = cfg.url;
          key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
        };
      };
    };

    topology.self.services.jellyfin = {
      info = lib.mkForce "";
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
