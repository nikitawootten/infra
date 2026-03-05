{
  flake.nixosModules.zfs = {
    services.zfs.autoScrub.enable = true;

    boot.supportedFilesystems = [ "zfs" ];
  };
}
