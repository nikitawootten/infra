{ lib, config, ... }:
let cfg = config.homelab.media.prowlarr;
in {
  options.homelab.media.prowlarr =
    config.lib.homelab.mkServiceOptionSet "Prowlarr" "prowlarr" cfg;

  config = lib.mkIf cfg.enable {
    services.prowlarr = { enable = true; };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    homelab.media.homepageConfig.Prowlarr = {
      priority = lib.mkDefault 5;
      config = {
        description = "Prowlarr";
        href = "https://${cfg.domain}";
        icon = "prowlarr.png";
      };
    };

    topology.self.services.prowlarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
