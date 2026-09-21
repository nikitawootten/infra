{ ... }:
{
  flake.nixosModules.protonvpn-torrent =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.protonvpn-torrent;
      interface = "wg-proton";
    in
    {
      options.services.protonvpn-torrent = {
        enable = lib.mkEnableOption "Proton WireGuard routing and isolation for the torrent service";
        privateKeyFile = lib.mkOption {
          type = lib.types.path;
          description = "Runtime path to the decrypted WireGuard private key, readable by systemd-network.";
        };
        user = lib.mkOption {
          type = lib.types.str;
          default = "qbittorrent";
          description = "Service account whose traffic must stay inside WireGuard.";
        };
        webuiPort = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Loopback Web UI/API port exempted from VPN isolation.";
        };
      };

      config = lib.mkIf cfg.enable {
        networking.networkmanager.unmanaged = [ "interface-name:${interface}" ];
        networking.firewall = {
          backend = "iptables";
          package = pkgs.iptables;
          checkReversePath = "loose";
          # The allocated port varies.
          interfaces.${interface} = {
            allowedTCPPortRanges = [
              {
                from = 1024;
                to = 65535;
              }
            ];
            allowedUDPPortRanges = [
              {
                from = 1024;
                to = 65535;
              }
            ];
          };
        };

        networking.nftables = {
          enable = true;
          flushRuleset = false;
          preCheckRuleset = ''
            sed -i 's/meta skuid "${cfg.user}"/meta skuid 0/g' ruleset.conf
          '';
          tables.protonvpn_killswitch = {
            family = "inet";
            content = ''
              chain output {
                type filter hook output priority 0; policy accept;
                # Encrypted WireGuard packets can retain the originating UID.
                # The unprivileged client/helper cannot set this packet mark.
                meta mark 51820 accept
                meta skuid "${cfg.user}" oifname "${interface}" accept
                meta skuid "${cfg.user}" oifname "lo" ip daddr 127.0.0.1 tcp dport ${toString cfg.webuiPort} accept
                meta skuid "${cfg.user}" oifname "lo" ip daddr 127.0.0.1 tcp sport ${toString cfg.webuiPort} ct state established accept
                meta skuid "${cfg.user}" counter reject with icmpx type admin-prohibited
              }
            '';
          };
        };

        systemd.network = {
          enable = true;
          netdevs."50-protonvpn" = {
            netdevConfig = {
              Kind = "wireguard";
              Name = interface;
            };
            wireguardConfig = {
              PrivateKeyFile = cfg.privateKeyFile;
              RouteTable = 51820;
              FirewallMark = 51820;
            };
            wireguardPeers = [
              {
                PublicKey = "p/sg7scJ5PshmIss9E/I2Y/dwM1EeEpqoE+YnR7JpWU=";
                Endpoint = "79.135.104.39:51820";
                AllowedIPs = [ "0.0.0.0/0" ];
                PersistentKeepalive = 25;
              }
            ];
          };
          networks."50-protonvpn" = {
            matchConfig.Name = interface;
            address = [ "10.2.0.2/32" ];
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = false;
              LinkLocalAddressing = "no";
            };
            linkConfig = {
              MTUBytes = 1420;
              RequiredForOnline = false;
            };
            routingPolicyRules = [
              {
                User = cfg.user;
                Table = 51820;
                Priority = 100;
                Family = "ipv4";
              }
            ];
          };
        };

        systemd.timers.protonvpn-port-forward = {
          description = "Renew Proton NAT-PMP mappings every 45 seconds";
          bindsTo = [ "qbittorrent.service" ];
          partOf = [ "qbittorrent.service" ];
          timerConfig = {
            OnActiveSec = "1s";
            OnUnitActiveSec = "45s";
            AccuracySec = "1s";
          };
        };

        systemd.services.protonvpn-port-forward = {
          description = "Renew Proton NAT-PMP lease and update qBittorrent";
          bindsTo = [
            "nftables.service"
            "qbittorrent.service"
          ];
          after = [
            "nftables.service"
            "qbittorrent.service"
          ];
          path = [ pkgs.libnatpmp ];
          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            ExecStart = "${pkgs.python3}/bin/python3 ${./protonvpn-port-forward.py} http://127.0.0.1:${toString cfg.webuiPort}";
            Restart = "on-failure";
            RestartSec = 5;
            TimeoutStartSec = "35s";
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            PrivateDevices = true;
            CapabilityBoundingSet = "";
            RestrictAddressFamilies = [ "AF_INET" ];
          };
        };
      };
    };
}
