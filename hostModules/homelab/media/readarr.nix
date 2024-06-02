{ lib, config, ... }:
let cfg = config.homelab.media.readarr;
in {
  options.homelab.media.readarr =
    config.lib.homelab.mkServiceOptionSet "Readarr" "readarr" cfg;

  config = lib.mkIf cfg.enable {
    services.readarr = {
      enable = true;
      group = config.homelab.media.group;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8787";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    homelab.media.homepageConfig.Readarr = {
      priority = lib.mkDefault 3;
      config = {
        description = "Readarr";
        href = "https://${cfg.domain}";
        icon = "readarr.png";
      };
    };

    topology.self.services.readarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
