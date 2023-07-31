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
        "${config.lib.lab.mkConfigDir "jellyfin"}/:/config"
        "${config.personal.lab.media.media-dir}/:/media"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "jellyfin";
        subdomain = "hypnos";
        port = "8096";
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      Hypnos = {
        icon = "jellyfin.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "hypnos"}";
        description = "Jellyfin: Media server";
        server = "my-docker";
        container = "jellyfin";
        widget = {
          type = "jellyfin";
          url = "https://${config.lib.lab.mkServiceSubdomain "hypnos"}";
          key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
          enableBlocks = true;
          enableNowPlaying = true;
        };
      };
    }
  ];

  networking.firewall.allowedUDPPorts = [
    1900
    7359
  ];
}