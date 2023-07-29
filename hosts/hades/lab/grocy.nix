{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.grocy = {
    service = {
      container_name = "grocy";
      image = "lscr.io/linuxserver/grocy";
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "9283:80"
      ];
      volumes = [
        "/backplane/applications/grocy/:/config"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "grocy";
        subdomain = "pomegranate";
      } // config.lib.lab.mkHomepageLabels {
        name = "Pomegranate";
        description = "Managing grocies in the underworld with Grocy";
        group = "Home";
        subdomain = "pomegranate";
        icon = "grocy.png";
      };
      useHostStore = true;
    };
  };
}