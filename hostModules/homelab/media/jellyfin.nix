{ lib, config, ... }:
let cfg = config.homelab.media.jellyfin;
in {
  options.homelab.media.jellyfin =
    config.lib.homelab.mkServiceOptionSet "Jellyfin" "jellyfin" cfg;

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

    networking.firewall.allowedUDPPorts = [ 1900 7359 ];

    homelab.media.homepageConfig.Jellyfin = {
      priority = lib.mkDefault 1;
      config = {
        description = "Jellyfin";
        href = "https://${cfg.domain}";
        icon = "jellyfin.png";
      };
    };

    topology.self.services.jellyfin = {
      info = lib.mkForce "";
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
