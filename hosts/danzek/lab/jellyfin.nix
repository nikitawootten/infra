{ ... }:
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
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.jellyfin.rule" = "Host(`danzek.arpa.nikita.computer`)";
        "traefik.http.routers.jellyfin.entrypoints" = "web";
        "traefik.http.routers.jellyfin.service" = "jellyfin";
        "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
      };
      useHostStore = true;
    };
  };

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}