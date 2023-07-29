{ ... }:
{
  imports = [
    ./keycloak.nix
    ./oauth2-proxy.nix
    ./openldap.nix
  ];
}