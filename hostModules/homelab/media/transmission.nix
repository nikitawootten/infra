{ lib, config, ... }:
let
  cfg = config.homelab.media.transmission;
  kanidmGroup = "transmission_users";
  serviceUrl = "http://127.0.0.1:9091";
in {
  options.homelab.media.transmission =
    (config.lib.homelab.mkServiceOptionSet "Transmission" "transmission" cfg)
    // {
      transmissionEnvFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the Transmission env file";
      };
    };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.transmission = {
      image = "haugene/transmission-openvpn";
      environment = {
        # TODO: Set up a user for Transmission
        PUID = "1000";
        PGID = toString config.users.groups.${config.homelab.media.group}.gid;
        LOCAL_NETWORK = "10.69.0.0/24";
        OPENVPN_OPTS = "--inactive 3600 --ping 10 --ping-exit 60";
      };
      environmentFiles = [ cfg.transmissionEnvFile ];
      ports = [ "9091:9091" ];
      volumes = [
        "${config.homelab.media.mediaRoot}/torrents:/data"
        "${config.homelab.media.configRoot}/transmission:/config"
      ];
      extraOptions =
        [ "--cap-add=NET_ADMIN,NET_RAW,mknod" "--device" "/dev/net/tun" ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = serviceUrl;
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
    services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
      allowed_groups = [ kanidmGroup ];
    };
    homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

    homelab.media.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 2;
      config = {
        description = "Web torrent client";
        href = cfg.url;
        icon = "transmission.png";
        siteMonitor = serviceUrl;
      };
    };

    topology.self.services.transmission = {
      name = cfg.name;
      icon = "services.transmission";
      details.listen.text = lib.mkForce cfg.domain;
    };
  };
}
