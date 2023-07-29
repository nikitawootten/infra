{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.radarr = {
    service = {
      container_name = "radarr";
      image = "lscr.io/linuxserver/radarr";
      environment = {
        PUID = 1000;
        PGID = 1000;
        TZ = "America/New_York";
      };
      ports = [ "7878:7878" ];
      volumes = [
        "${config.lib.lab.mkConfigDir "radarr"}/:/config"
        "${config.personal.lab.media.media-dir}/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "radarr";
        subdomain = "atropos";
        forwardAuth = true;
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      Atropos = {
        icon = "radarr.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "atropos"}";
        description = "Radarr: TV series management";
        server = "my-docker";
        container = "radarr";
        widget = {
          type = "radarr";
          url = "http://radarr:7878";
          key = "{{HOMEPAGE_VAR_RADARR_APIKEY}}";
        };
      };
    }
  ];
}