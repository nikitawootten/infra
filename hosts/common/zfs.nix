{ config, pkgs, ... }:

{
  # hold kernel version to latest that supports zfs
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
}
