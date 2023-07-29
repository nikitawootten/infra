{ lib, ... }:
{
  imports = [
    ./base.nix
    ./flatpak.nix
    ./ssh-server.nix
    ./sudo.nix
    ./tailscale.nix
    ./upgrade-diff.nix
  ];

  upgrade-diff.enable = lib.mkDefault true;
}
