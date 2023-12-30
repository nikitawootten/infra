{ ... }:
{
  imports = [
    ./keycloak.nix
    ./oauth2-proxy.nix
    ./authentik.nix
  ];
}
