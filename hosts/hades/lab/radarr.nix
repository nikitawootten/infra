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
        "/backplane/applications/radarr/:/config"
        "/backplane/media/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "radarr";
        subdomain = "atropos";
      };
    };
  };
}