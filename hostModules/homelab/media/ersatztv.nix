{ lib, config, ... }:
let cfg = config.homelab.media.ersatztv;
in {
  options.homelab.media.ersatztv =
    (config.lib.homelab.mkServiceOptionSet "ErsatzTV" "ersatztv" cfg) // {
      image = lib.mkOption {
        type = lib.types.str;
        default = "jasongdove/ersatztv:latest";
        example = "jasongdove/ersatztv:latest-nvidia";
        description = "Docker image to use";
      };
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.homelab.media.configRoot}/ersatztv";
        description = "Directory to store ErsatzTV configuration";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 8409;
        description = "Port to expose ErsatzTV on";
      };
    };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.ersatztv = {
      image = cfg.image;
      environment = { TZ = config.time.timeZone; };
      ports = [ "${toString cfg.port}:8409" ];
      volumes = [
        "${cfg.configDir}:/root/.local/share/ersatztv"
        "${config.homelab.media.mediaRoot}:${config.homelab.media.mediaRoot}:ro"
      ];
      extraOptions = [ "--device=nvidia.com/gpu=all" ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        recommendedProxySettings = true;
      };
    };
  };
}
