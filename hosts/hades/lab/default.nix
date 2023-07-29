{ arion, agenix, ... }:
{
  imports = [
    arion.nixosModules.arion
    agenix.nixosModules.default
    ./actual.nix
    ./grocy.nix
    ./homepage.nix
    ./jellyfin.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./traefik.nix
    ./transmission-ovpn.nix
  ];

  virtualisation.arion.backend = "docker";
}