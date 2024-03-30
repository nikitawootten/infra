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
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = {};

    homelab.media.jellyfin.enable = true;
    homelab.media.transmission.enable = true;
  };
}
