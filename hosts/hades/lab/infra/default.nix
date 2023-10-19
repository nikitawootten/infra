{ ... }:
{
  imports = [
    ./omada-controller.nix
    ./traefik.nix
    ./watchtower.nix
  ];
}
