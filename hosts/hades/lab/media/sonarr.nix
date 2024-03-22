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
        "${config.lib.lab.mkConfigDir "sonarr"}/:/config"
        "${config.personal.lab.media.media-dir}/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "sonarr";
        subdomain = "sonarr";
        forwardAuth = true;
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      Sonarr = {
        icon = "sonarr.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "sonarr"}";
        description = "TV series management";
        server = "my-docker";
        container = "sonarr";
        widget = {
          type = "sonarr";
          url = "http://sonarr:8989";
          key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
        };
      };
    }
  ];
}
