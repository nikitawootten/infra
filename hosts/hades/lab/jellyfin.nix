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
      # } // config.lib.lab.mkHomepageLabels {
      #   name = "Hypnos";
      #   description = "Jellyfin media server";
      #   group = "Media";
      #   subdomain = "hypnos";
      #   icon = "jellyfin.png";
      # } // {
      #   "homepage.widget.type" = "jellyfin";
      #   "homepage.widget.url" = "hypnos.${hostname}.${config.lib.lab.domain}";
      #   "homepage.widget.key" = "\"{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}\"";
      #   "homepage.widget.enableBlocks" = "true";
      #   "homepage.widget.enableNowPlaying" = "true";
      };
      useHostStore = true;
    };
  };

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}