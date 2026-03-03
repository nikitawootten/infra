{
  flake.modules.nixos.zfs = {
    services.zfs.autoScrub.enable = true;

    boot.supportedFilesystems = [ "zfs" ];
  };
}
