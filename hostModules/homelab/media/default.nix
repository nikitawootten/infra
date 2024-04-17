{ lib, config, ...}:
let
  cfg = config.homelab.media;
in
{
  imports = [
    ./jellyfin.nix
    ./transmission.nix
  ];

  options.homelab.media = {
    enable = lib.mkEnableOption "Enable media stack";
    group = lib.mkOption {
      type = lib.types.str;
      description = "The group to use for media services";
      default = "media";
    };
    storageRoot = lib.mkOption {
      type = lib.types.str;
      description = "The root directory for media storage";
    };
    homepageCategory = lib.mkOption {
      type = lib.types.str;
      default = "Media";
      description = "Homepage category for the media stack";
    };
    homepageConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Homepage configuration for the media stack";
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = {};

    homelab.media.jellyfin.enable = true;
    homelab.media.transmission.enable = true;

    services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
      priority = lib.mkDefault 4;
      config = cfg.homepageConfig;
    };

    services.homepage-dashboard.widgets = [
      {
        resources = {
          label = "Media Storage";
          disk = cfg.storageRoot;
        };
      }
    ];
  };
}