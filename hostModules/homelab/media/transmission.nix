{ lib, config, ... }:
let
  cfg = config.homelab.media.transmission;
in
{
  options.homelab.media.transmission = config.lib.homelab.mkServiceOptionSet "Transmission" "transmission" cfg;

  config = lib.mkIf cfg.enable {
    services.transmission = {
      enable = true;
      group = config.homelab.media.group;
      settings = {
        download-dir = "${config.homelab.media.storageRoot}/torrents/completed";
        incomplete-dir-enabled = true;
        incomplete-dir = "${config.homelab.media.storageRoot}/torrents/incomplete";
        watch-dir-enabled = true;
        watch-dir = "${config.homelab.media.storageRoot}/torrents/watch";

        rpc-whitelist = "127.*,192.168.*,10.*";
        rpc-whitelist-enabled = true;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = cfg.domain;
        rpc-bind-address = "192.168.15.1"; # Bind RPC/WebUI to bridge address

        rpc-authentication-required = false;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://192.168.15.1:${toString config.services.transmission.settings.rpc-port}";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_pass_header X-Transmission-Session-Id;
          proxy_set_header X-NginX-Proxy true;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          proxy_pass_header X-Transmission-Session-Id;
        '';
      };
    };

    systemd.services.transmission.vpnconfinement = {
      enable = true;
      vpnnamespace = config.homelab.vpn.namespace;
    };

    vpnnamespaces.${config.homelab.vpn.namespace} = {
      portMappings = let
        port = config.services.transmission.settings.rpc-port;
      in [
        { from = port; to = port; }
      ];
      openVPNPorts = [{
        port = config.services.transmission.settings.peer-port;
        protocol = "both";
      }];
    };

    homelab.media.homepageConfig.Transmission = {
      priority = lib.mkDefault 2;
      config = {
        description = "Transmission";
        href = "https://${cfg.domain}";
        icon = "transmission.png";
      };
    };
  };
}
