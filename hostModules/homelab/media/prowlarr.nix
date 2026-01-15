{ lib, config, ... }:
let
  cfg = config.homelab.media.prowlarr;
  kanidmGroup = "prowlarr_users";
  serviceUrl = "http://127.0.0.1:9696";
in
{
  options.homelab.media.prowlarr =
    config.lib.homelab.mkServiceOptionSet "Prowlarr" "prowlarr" cfg
    // {
      authHeaderFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = lib.mdDoc ''
          Path to a file containing the basic auth credentials used by Prowlarr.
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
    services.prowlarr = {
      enable = true;
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

    topology.self.services.prowlarr = {
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
