let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
  iris_keyset = [ keys.iris ] ++ keys.trusted_users;
in {
  "traefik.env.age".publicKeys = [ keys.hades keys.iris ] ++ keys.trusted_users;
  "keycloak-db-pw.age".publicKeys = hades_keyset;
  "transmission.env.age".publicKeys = hades_keyset;
}
