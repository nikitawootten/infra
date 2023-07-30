{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.readarr = {
    service = {
      container_name = "readarr";
      image = "lscr.io/linuxserver/readarr:develop";
      environment = {
        PUID = 1000;
        PGID = 1000;
        TZ = "America/New_York";
      };
      ports = [ "8787:8787" ];
      volumes = [
        "${config.lib.lab.mkConfigDir "readarr"}/:/config"
        "${config.personal.lab.media.media-dir}/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "readarr";
        subdomain = "arae";
        forwardAuth = true;
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      Area = {
        icon = "readarr.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "arae"}";
        description = "Readarr: Book and Audiobook management";
        server = "my-docker";
        container = "readarr";
        widget = {
          type = "readarr";
          url = "http://readarr:8787";
          key = "{{HOMEPAGE_VAR_READARR_APIKEY}}";
        };
      };
    }
  ];
}