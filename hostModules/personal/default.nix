{ lib, ... }:
{
  imports = [
    ./base.nix
    ./docker.nix
    ./dslr-webcam.nix
    ./flatpak.nix
    ./gnome.nix
    ./networkmanager.nix
    ./nvidia.nix
    ./printing.nix
    ./sound.nix
    ./ssh-server.nix
    ./printing.nix
    ./steam.nix
    ./tailscale.nix
    ./upgrade-diff.nix
    ./virtualbox.nix
    ./vpn.nix
    ./wireshark.nix
    ./zfs.nix
    ./zsa.nix
  ];

  personal.base.enable = lib.mkDefault true;
  personal.upgrade-diff.enable = lib.mkDefault true;
  personal.ssh-server.enable = lib.mkDefault true;
  personal.tailscale.enable = lib.mkDefault true;
}