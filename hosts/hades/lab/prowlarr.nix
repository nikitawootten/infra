{ config, ... }:
let
  service = "prowlarr";
  subdomain = "lachesis";
in
{
  virtualisation.arion.projects.lab.settings.services.prowlarr = {
    service = {
      container_name = service;
      image = "lscr.io/linuxserver/${service}";
      environment = {
        TZ = "America/New_York";
        PUID = 1000;
        PGID = 1000;
      };
      ports = [
        "9696:9696"
      ];
      volumes = [
        "/backplane/applications/${service}/:/config"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = service;
        inherit subdomain;
        forwardAuth = true;
      };
    };
  };
}