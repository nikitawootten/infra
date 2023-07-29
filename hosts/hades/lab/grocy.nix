{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.grocy = {
    service = {
      container_name = "grocy";
      image = "lscr.io/linuxserver/grocy";
      environment = {
        TZ = "America/New_York";
        PUID = 1000;
        PGID = 1000;
      };
      ports = [
        "9283:80"
      ];
      volumes = [
        "${config.lib.lab.mkConfigDir "grocy"}/:/config"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "grocy";
        subdomain = "pomegranate";
      } // config.lib.lab.mkHomepageLabels {
        name = "Pomegranate";
        description = "Grocy: Kitchen inventory management";
        group = "Home";
        subdomain = "pomegranate";
        icon = "grocy.png";
      };
    };
  };
}