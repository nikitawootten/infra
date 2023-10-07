{ lib, config, ... }:
let
  cfg = config.personal.zfs;
in
{
  options.personal.zfs = {
    enable = lib.mkEnableOption "zfs modules";
  };

  config = lib.mkIf cfg.enable {
    # hold kernel version to latest that supports zfs
    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    boot.supportedFilesystems = [ "zfs" ];
  };
}
