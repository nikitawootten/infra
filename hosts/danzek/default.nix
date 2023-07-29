{ pkgs, hostname, username, ... }:
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
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.interfaces.eth0.ipv4.addresses = [{
    address = "192.168.101.1";
    prefixLength = 16;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.5" ];
}
