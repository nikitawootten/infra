{ arion, ... }:
{
  imports = [
    arion.nixosModules.arion
    ./jellyfin.nix
    ./traefik
  ];

  virtualisation.arion.backend = "docker";
}