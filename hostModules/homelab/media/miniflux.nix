{ config, lib, ... }:
let
  cfg = config.homelab.media.miniflux;
  kanidmGroup = "miniflux_users";
  clientId = "miniflux";
in {
  options.homelab.media.miniflux =
    config.lib.homelab.mkServiceOptionSet "Miniflux" "miniflux" cfg // {
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the Miniflux client secret";
      };
      envFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing sensitive environment variables";
      };
    };

  config = lib.mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      createDatabaseLocally = true;
      config = {
        LISTEN_ADDR = "localhost:3003";
        CREATE_ADMIN = "0";
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_CLIENT_ID = clientId;
        # OAUTH2_CLIENT_SECRET provided via envFile
        OAUTH2_REDIRECT_URL = "${cfg.url}/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT =
          "https://${config.homelab.infra.kanidm.domain}/oauth2/openid/${clientId}";
        OAUTH2_USER_CREATION = "1";
        DISABLE_LOCAL_AUTH = "1";
      };
      adminCredentialsFile = cfg.envFile;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass =
          "http://${toString config.services.miniflux.config.LISTEN_ADDR}";
        recommendedProxySettings = true;
      };
    };

    services.kanidm.provision.groups.${kanidmGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.systems.oauth2.${clientId} = {
      displayName = cfg.name;
      originUrl = "${cfg.url}/oauth2/oidc/callback";
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps.${kanidmGroup} = [ "email" "openid" "profile" ];
    };

    homelab.media.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 6;
      config = {
        description = "RSS feed reader";
        url = cfg.url;
        icon = "miniflux.png";
        href = cfg.url;
        siteMonitor = cfg.url;
        widget = {
          type = "miniflux";
          url = cfg.url;
          key = "{{HOMEPAGE_VAR_MINIFLUX_API_KEY}}";
        };
      };
    };
  };
}
