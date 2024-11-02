{ lib, config, ... }:
let cfg = config.personal.zfs;
in {
  options.personal.zfs = { enable = lib.mkEnableOption "zfs modules"; };

  config = lib.mkIf cfg.enable {
    services.zfs.autoScrub.enable = true;

    boot.supportedFilesystems = [ "zfs" ];
  };
}
