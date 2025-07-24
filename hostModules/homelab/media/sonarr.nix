{ lib, config, ... }:
let
  cfg = config.homelab.media.sonarr;
  kanidmGroup = "sonarr_users";
  serviceUrl = "http://127.0.0.1:8989";
in {
  options.homelab.media.sonarr =
    config.lib.homelab.mkServiceOptionSet "Sonarr" "sonarr" cfg // {
      authHeaderFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = lib.mdDoc ''
          Path to a file containing the basic auth credentials used by Sonarr.
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
    services.sonarr = {
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
    homelab.auth.oauth2-proxy.groups = [ kanidmGroup ];

    homelab.media.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 3;
      config = {
        description = "TV show download manager";
        href = cfg.url;
        icon = "sonarr.png";
        siteMonitor = serviceUrl;
        widget = {
          type = "sonarr";
          url = serviceUrl;
          key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
        };
      };
    };

    topology.self.services.sonarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
