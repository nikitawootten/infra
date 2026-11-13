{ self, ... }:
{
  flake.nixosModules.homelab-qbittorrent =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.media.qbittorrent;
      kanidmGroup = "qbittorrent_users";
      serviceUrl = "http://127.0.0.1:8080";
      downloadRoot = "${config.homelab.media.mediaRoot}/torrents";
      torrentResolver = pkgs.writeText "torrent-resolv.conf" "nameserver 10.2.0.1\n";
      torrentResolvedDirectory = pkgs.linkFarm "torrent-resolved" [
        {
          name = "stub-resolv.conf";
          path = torrentResolver;
        }
        {
          name = "resolv.conf";
          path = torrentResolver;
        }
      ];
    in
    {
      imports = [ self.nixosModules.protonvpn-torrent ];

      options.homelab.media.qbittorrent =
        (config.lib.homelab.mkServiceOptionSet "qBittorrent" "qbittorrent" cfg)
        // {
          wireguardPrivateKeyFile = lib.mkOption {
            type = lib.types.path;
            description = "Runtime path to the decrypted Proton WireGuard private key.";
          };
        };

      config = lib.mkIf cfg.enable {
        homelab.criticalServices = [ "qbittorrent" ];

        services.protonvpn-torrent = {
          enable = true;
          privateKeyFile = cfg.wireguardPrivateKeyFile;
        };
        services.qbittorrent = {
          enable = true;
          group = config.homelab.media.group;
          profileDir = "${config.homelab.media.configRoot}/qbittorrent";
          webuiPort = 8080;
          openFirewall = false;
          serverConfig = {
            LegalNotice.Accepted = true;
            Network.PortForwardingEnabled = false;
            BitTorrent.Session = {
              Interface = "wg-proton";
              InterfaceAddress = "10.2.0.2";
              # https://trash-guides.info/Downloaders/qBittorrent/Basic-Setup/
              TorrentContentLayout = "Original";
              DisableAutoTMMByDefault = false;
              DisableAutoTMMTriggers = {
                CategoryChanged = false;
                DefaultSavePathChanged = false;
                CategorySavePathChanged = false;
              };
              DefaultSavePath = "${downloadRoot}/complete";
              TempPath = "${downloadRoot}/incomplete";
              TempPathEnabled = true;
              # Proton's lease is managed by protonvpn-port-forward.service.
              LSDEnabled = false;
              BTProtocol = "TCP";
              uTPRateLimited = true;
              IncludeOverheadInLimits = false;
              IgnoreLimitsOnLAN = false;
              Encryption = 0;
              AnonymousModeEnabled = false;
              QueueingSystemEnabled = false;
              GlobalMaxRatio = -1;
              GlobalMaxSeedingMinutes = -1;
              GlobalMaxInactiveSeedingMinutes = -1;
              ShareLimitAction = "Stop";
              AddTrackersEnabled = false;
              AddTrackersFromURLEnabled = false;
            };
            Preferences.WebUI = {
              Address = "127.0.0.1";
              LocalHostAuth = false;
              ServerDomains = cfg.domain;
              HostHeaderValidation = true;
              CSRFProtection = true;
              # Nginx enforces SSO; local *arr/API clients are trusted.
              ReverseProxySupportEnabled = false;
            };
          };
        };

        systemd.tmpfiles.rules = [
          "d ${config.services.qbittorrent.profileDir} 0755 qbittorrent ${config.homelab.media.group} -"
          "d ${downloadRoot} 2775 qbittorrent ${config.homelab.media.group} -"
          "d ${downloadRoot}/complete 2775 qbittorrent ${config.homelab.media.group} -"
          "d ${downloadRoot}/incomplete 2775 qbittorrent ${config.homelab.media.group} -"
        ];
        systemd.services.qbittorrent = {
          # Stop the client before nftables removes its table.
          # Restart it after an explicit firewall restart.
          bindsTo = [ "nftables.service" ];
          partOf = [ "nftables.service" ];
          after = [
            "nftables.service"
            "systemd-networkd.service"
          ];
          wants = [ "protonvpn-port-forward.timer" ];
          restartTriggers = [
            (config.environment.etc."resolv.conf".source or "/etc/resolv.conf")
            config.environment.etc."nsswitch.conf".source
          ];
          unitConfig.RequiresMountsFor = [
            downloadRoot
            config.services.qbittorrent.profileDir
          ];
          serviceConfig = {
            UMask = "0002";
            Restart = "on-failure";
            RestartSec = 5;
            # Avoid DNS requests being delegated to a host resolver outside the
            # filtered UID. AF_UNIX is already excluded by the upstream service.
            BindReadOnlyPaths = [
              "${pkgs.writeText "torrent-nsswitch.conf" "hosts: files dns\n"}:/etc/nsswitch.conf"
            ]
            ++ (
              if config.services.resolved.enable then
                [ "${torrentResolvedDirectory}:/run/systemd/resolve" ]
              else
                [ "${torrentResolver}:/etc/resolv.conf" ]
            );
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
        services.oauth2-proxy.nginx.virtualHosts.${cfg.domain}.allowed_groups = [ kanidmGroup ];
        homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

        homelab.media.managementHomepageConfig.${cfg.name} = {
          priority = lib.mkDefault 2;
          config = {
            description = "Web torrent client";
            href = cfg.url;
            icon = "qbittorrent.png";
            siteMonitor = serviceUrl;
          };
        };
      };
    };
}
