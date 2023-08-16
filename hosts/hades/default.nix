{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./lab
  ];

  personal.zfs.enable = true;
  personal.docker.enable = true;
  personal.nvidia.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub.mirroredBoots = [
    {
      devices = [ "/dev/disks/by-id/wwn-0x5000c5007e5f2beb-part3" ];
      path = "/boot-fallback";
    }
  ];

  networking.hostId = "45389833";
  boot.zfs.extraPools = [ "storage" ];
}
