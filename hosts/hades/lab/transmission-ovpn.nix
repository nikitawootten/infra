{ config, secrets, ... }:
{
  age.secrets.transmission-ovpn.file = secrets.transmission-ovpn;

  virtualisation.arion.projects.lab.settings.services.transmission-ovpn = {
    service = {
      container_name = "transmission-ovpn";
      image = "haugene/transmission-openvpn";
      ports = [ "9091:9091" ];
      environment = {
        PUID = 1000;
        PGID = 1000;
      };
      env_file = [ config.age.secrets.transmission-ovpn.path ];
      volumes = [
        "/backplane/applications/transmission-ovpn/:/config"
        "/backplane/media/torrents/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "transmission-ovpn";
        subdomain = "tartarus";
        port = "9091";
        forwardAuth = true;
      };
      capabilities = { NET_ADMIN = true; };
      sysctls = { "net.ipv6.conf.all.disable_ipv6" = 0; };
      restart = "unless-stopped";
    };
  };
}