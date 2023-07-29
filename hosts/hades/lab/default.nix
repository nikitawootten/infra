{ arion, agenix, ... }:
{
  imports = [
    arion.nixosModules.arion
    agenix.nixosModules.default
    ./grocy.nix
    ./jellyfin.nix
    ./traefik.nix
  ];

  virtualisation.arion.backend = "docker";
}