{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.ersatztv = {
    service = {
      container_name = "ersatztv";
      image = "jasongdove/ersatztv:latest-nvidia";
      environment = {
        TZ = "America/New_York";
      };
      ports = [ "8409:8409" ];
      volumes = [
        "${config.lib.lab.mkConfigDir "ersatztv"}:/root/.local/share/ersatztv"
        "${config.personal.lab.media.media-dir}/:/media"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "ersatztv";
        subdomain = "morpheus";
        forwardAuth = true;
      } // config.lib.lab.mkHomepageLabels {
        name = "Morpheus";
        description = "ErsatzTV: Live TV server";
        group = "Media";
        subdomain = "morpheus";
        icon = "ersatztv.png";
      };
      restart = "unless-stopped";
    };
    # Override the resulting output to enable GPU support
    # See https://docs.docker.com/compose/gpu-support/
    # TODO: submit a patch to Arion
    out.service = {
      deploy.resources.reservations.devices = [
        {
          driver = "nvidia";
          count = 1;
          capabilities = [ "gpu" ];
        }
      ];
    };
  };
}