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
        "${config.lib.lab.mkConfigDir service}/:/config"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = service;
        inherit subdomain;
        forwardAuth = true;
      };
    };
  };

  personal.lab.homepage.media-services = [
    {
      Lachesis = {
        icon = "prowlarr.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "lachesis"}";
        description = "Prowlarr: Indexer";
        server = "my-docker";
        container = "prowlarr";
        widget = {
          type = "prowlarr";
          url = "http://prowlarr:9696";
          key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
        };
      };
    }
  ];
}