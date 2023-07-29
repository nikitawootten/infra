{ arion, agenix, ... }:
{
  imports = [
    arion.nixosModules.arion
    agenix.nixosModules.default
    ./actual.nix
    ./grocy.nix
    ./homepage.nix
    ./jellyfin.nix
    ./traefik.nix
  ];

  virtualisation.arion.backend = "docker";
}