{ ... }:
{
  imports = [
    ./base.nix
    ./ssh-server.nix
    ./sudo.nix
    ./tailscale.nix
  ];
}