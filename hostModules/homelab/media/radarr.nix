{ lib, config, ... }:
let
  cfg = config.homelab.media.radarr;
  kanidmGroup = "radarr_users";
  serviceUrl = "http://127.0.0.1:7878";
in {
  options.homelab.media.radarr =
    config.lib.homelab.mkServiceOptionSet "Radarr" "radarr" cfg // {
      authHeaderFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = lib.mdDoc ''
          Path to a file containing the basic auth credentials used by Radarr.
          The file should contain a single line in the format:
          ```
          proxy_set_header Authorization "Basic <base64-encoded-credentials>";
          ```
          where `<base64-encoded-credentials>` is the base64 encoding of `username:password`.
          ```
        '';
      };
    };

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = config.homelab.media.group;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = serviceUrl;
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = lib.optionalString (cfg.authHeaderFile != null) ''
          proxy_hide_header WWW-Authenticate;
          include ${cfg.authHeaderFile};
        '';
      };
    };
    services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
      allowed_groups = [ kanidmGroup ];
    };
    homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

    homelab.media.homepageConfig.${cfg.name} = {
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

    topology.self.services.radarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
