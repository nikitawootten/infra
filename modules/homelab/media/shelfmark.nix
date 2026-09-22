{ ... }:
{
  flake.nixosModules.homelab-shelfmark =
    { lib, config, ... }:
    let
      cfg = config.homelab.media.shelfmark;
      kanidmGroup = "shelfmark_users";
      serviceUrl = "http://127.0.0.1:${config.services.shelfmark.environment.FLASK_PORT}";
      booksDir = "${config.homelab.media.mediaRoot}/books";
    in
    {
      options.homelab.media.shelfmark = config.lib.homelab.mkServiceOptionSet "Shelfmark" "shelfmark" cfg;

      config = lib.mkIf cfg.enable {
        services.shelfmark = {
          enable = true;
          environment = {
            FLASK_HOST = "127.0.0.1";
            AUTH_METHOD = "none"; # Access is controlled by oauth2-proxy below.
            SESSION_COOKIE_SECURE = "true";
            INGEST_DIR = booksDir;
            HARDLINK_TORRENTS = "false";
            HARDLINK_TORRENTS_AUDIOBOOK = "false";
            SEARCH_MODE = "universal";
            PROWLARR_URL = "http://127.0.0.1:9696";
            PROWLARR_TORRENT_CLIENT = "qbittorrent";
            QBITTORRENT_URL = "http://127.0.0.1:8080";
            QBITTORRENT_CATEGORY = "books";
          };
        };

        users.users.shelfmark = {
          isSystemUser = true;
          group = config.homelab.media.group;
        };
        systemd.tmpfiles.rules = [
          "d ${booksDir} 2775 shelfmark ${config.homelab.media.group} -"
        ];
        systemd.services.shelfmark = {
          unitConfig.RequiresMountsFor = [ booksDir ];
          serviceConfig = {
            # A stable identity permits ownership of files outside StateDirectory.
            DynamicUser = lib.mkForce false;
            User = "shelfmark";
            Group = config.homelab.media.group;
            StateDirectoryMode = "0700";
            UMask = lib.mkForce "0002";
            ReadWritePaths = [ booksDir ];
          };
        };

        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          useACMEHost = config.homelab.domain;
          locations."/" = {
            proxyPass = serviceUrl;
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
        services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
          allowed_groups = [ kanidmGroup ];
        };
        homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

        homelab.media.managementHomepageConfig.${cfg.name} = {
          priority = lib.mkDefault 2;
          config = {
            description = "Book download manager";
            href = cfg.url;
            icon = "shelfmark.png";
            siteMonitor = serviceUrl;
          };
        };
      };
    };
}
