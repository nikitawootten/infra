let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
  iris_keyset = [ keys.iris ] ++ keys.trusted_users;
in
{
  "traefik.env.age".publicKeys = [ keys.hades keys.iris ] ++ keys.trusted_users;

  "homepage.env.age".publicKeys = hades_keyset;
  "transmission-ovpn.env.age".publicKeys = hades_keyset;
  "watchtower.env.age".publicKeys = hades_keyset;
  "freshrss.env.age".publicKeys = hades_keyset;
  # Authentik Postgres DB auth
  "authentik-pg.env.age".publicKeys = hades_keyset;
  # Authentik secret
  "authentik.env.age".publicKeys = hades_keyset;

  "keycloak-db-pw.age".publicKeys = hades_keyset;
  "wg.conf.age".publicKeys = hades_keyset;
}
