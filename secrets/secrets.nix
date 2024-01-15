let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
in
{
  "homepage.env.age".publicKeys = hades_keyset;
  "traefik.env.age".publicKeys = hades_keyset;
  "transmission-ovpn.env.age".publicKeys = hades_keyset;
  "watchtower.env.age".publicKeys = hades_keyset;
  "freshrss.env.age".publicKeys = hades_keyset;
  # Authentik Postgres DB auth
  "authentik-pg.env.age".publicKeys = hades_keyset;
  # Authentik secret
  "authentik.env.age".publicKeys = hades_keyset;
}
