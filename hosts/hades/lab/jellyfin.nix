{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.jellyfin = {
    service = {
      container_name = "jellyfin";
      image = "lscr.io/linuxserver/jellyfin";
      environment = {
        PUID = 1000;
        PGID = 1000;
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
      };
    };
  };

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}