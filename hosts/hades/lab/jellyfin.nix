{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.jellyfin = {
    service = {
      container_name = "jellyfin";
      image = "lscr.io/linuxserver/jellyfin";
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "8096:8096"
        "8920:8920"
        "1900:1900"
        "7359:7359"
      ];
      volumes = [
        "/backplane/applications/jellyfin/:/config"
        "/backplane/media/:/media"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "jellyfin";
        subdomain = "hypnos";
        port = "8096";
      } // config.lib.lab.mkHomepageLabels {
        name = "Hypnos";
        description = "Jellyfin media server";
        group = "Media";
        subdomain = "hypnos";
        icon = "jellyfin.png";
      };
      useHostStore = true;
    };
  };

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}