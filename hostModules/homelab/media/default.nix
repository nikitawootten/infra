{ lib, config, ... }:
let cfg = config.homelab.media;
in {
  imports = [
    ./audiobookshelf.nix
    ./ersatztv.nix
    ./jellyfin.nix
    ./miniflux.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./transmission.nix
  ];

  options.homelab.media = {
    enable = lib.mkEnableOption "Enable media stack";
    group = lib.mkOption {
      type = lib.types.str;
      description = "The group to use for media services";
      default = "media";
    };
    mediaRoot = lib.mkOption {
      type = lib.types.str;
      description = "The root directory for media storage";
    };
    configRoot = lib.mkOption {
      type = lib.types.str;
      description = "The root directory for misc. media configuration";
    };
    homepageCategory = lib.mkOption {
      type = lib.types.str;
      default = "Media";
      description = "Homepage category for the media stack";
    };
    homepageConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Homepage configuration for the media stack";
      default = { };
    };
    managementHomepageCategory = lib.mkOption {
      type = lib.types.str;
      default = "Media Management";
      description = "Homepage category for the media management stack";
    };
    managementHomepageConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Homepage configuration for the media management stack";
      default = { };
    };
    enableSambaShare =
      lib.mkEnableOption "Enable Samba share for media storage";
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };

    homelab.media.audiobookshelf.enable = lib.mkDefault true;
    homelab.media.ersatztv.enable = lib.mkDefault true;
    homelab.media.jellyfin.enable = lib.mkDefault true;
    homelab.media.transmission.enable = lib.mkDefault true;
    homelab.media.prowlarr.enable = lib.mkDefault true;
    homelab.media.radarr.enable = lib.mkDefault true;
    homelab.media.sonarr.enable = lib.mkDefault true;
    homelab.media.enableSambaShare = lib.mkDefault true;
    homelab.media.miniflux.enable = lib.mkDefault true;

    services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
      priority = lib.mkDefault 10;
      config = cfg.homepageConfig;
    };
    services.homepage-dashboard.services-declarative.${cfg.managementHomepageCategory} =
      {
        priority = lib.mkDefault 5;
        config = cfg.managementHomepageConfig;
      };

    services.homepage-dashboard.widgets = [{
      resources = {
        label = "Media Storage";
        disk = cfg.mediaRoot;
      };
    }];

    services.samba.settings = lib.mkIf cfg.enableSambaShare {
      media = {
        path = cfg.mediaRoot;
        writable = true;
        createMask = "0775";
        directoryMask = "0775";
        "force group" = cfg.group;
        comment = "Media storage";
      };
    };
  };
}
