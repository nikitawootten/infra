{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./k3s.nix
    ./nfs.nix
  ];

  # TODO: derive this in a more pure way?
  networking.hostId = "2bda7775";

  boot.zfs.extraPools = [ "backplane" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
}
