{ lib, config, ... }:
let cfg = config.homelab.media.sonarr;
in {
  options.homelab.media.sonarr =
    config.lib.homelab.mkServiceOptionSet "Sonarr" "sonarr" cfg;

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = config.homelab.media.group;
    };

    # TODO: Remove once Sonarr build is updated: https://github.com/NixOS/nixpkgs/issues/360592
    nixpkgs.config.permittedInsecurePackages =
      [ "dotnet-sdk-6.0.428" "aspnetcore-runtime-6.0.36" ];

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    homelab.media.homepageConfig.Sonarr = {
      priority = lib.mkDefault 3;
      config = {
        description = "Sonarr";
        href = "https://${cfg.domain}";
        icon = "sonarr.png";
      };
    };

    topology.self.services.sonarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
