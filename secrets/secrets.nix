let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
in
{
  "homepage.env.age".publicKeys = hades_keyset;
  "openldap.rootpw.age".publicKeys = hades_keyset;
  "traefik.env.age".publicKeys = hades_keyset;
  "transmission-ovpn.env.age".publicKeys = hades_keyset;
  "keycloak.env.age".publicKeys = hades_keyset;
  "postgres.env.age".publicKeys = hades_keyset;
  "oauth2-proxy.env.age".publicKeys = hades_keyset;
  "watchtower.env.age".publicKeys = hades_keyset;
  "freshrss.env.age".publicKeys = hades_keyset;
}
