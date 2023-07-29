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
        "${config.lib.lab.mkConfigDir "transmission-ovpn"}/:/config"
        "${config.personal.lab.media.media-dir}/torrents/:/data"
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
  
  personal.lab.homepage.media-services = [
    {
      Tartarus = {
        icon = "transmission.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "tartarus"}/transmission";
        description = "Transmission: Download server";
        server = "my-docker";
        container = "transmission-ovpn";
        widget = {
          type = "transmission";
          url = "http://transmission-ovpn:9091";
          rpcUrl = "/transmission/";
        };
      };
    }
  ];
}