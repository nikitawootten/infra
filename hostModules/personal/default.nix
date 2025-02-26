{ lib, ... }: {
  imports = [
    ./roles
    ./base.nix
    ./docker.nix
    ./flatpak.nix
    ./gnome.nix
    ./networkmanager.nix
    ./nvidia.nix
    ./printing.nix
    ./sound.nix
    ./ssh-server.nix
    ./printing.nix
    ./stylix.nix
    ./tailscale.nix
    ./upgrade-diff.nix
    ./user.nix
    ./virtualbox.nix
    ./zfs.nix
    ./zsa.nix
  ];

  personal.base.enable = lib.mkDefault true;
  personal.upgrade-diff.enable = lib.mkDefault true;
  personal.ssh-server.enable = lib.mkDefault true;
  personal.tailscale.enable = lib.mkDefault true;
}
