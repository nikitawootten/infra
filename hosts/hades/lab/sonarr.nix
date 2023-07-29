{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.sonarr = {
    service = {
      container_name = "sonarr";
      image = "lscr.io/linuxserver/sonarr";
      environment = {
        PUID = 1000;
        PGID = 1000;
        TZ = "America/New_York";
      };
      ports = [ "8989:8989" ];
      volumes = [
        "/backplane/applications/sonarr/:/config"
        "/backplane/media/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "sonarr";
        subdomain = "clotho";
        forwardAuth = true;
      };
      restart = "unless-stopped";
    };
  };
}