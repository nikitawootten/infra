let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
  iris_keyset = [ keys.iris ] ++ keys.trusted_users;
in {
  "traefik.env.age".publicKeys = [ keys.hades keys.iris keys.hermes ]
    ++ keys.trusted_users;
  "transmission.env.age".publicKeys = hades_keyset;
  "kanidm-password.age".publicKeys = hades_keyset;
}
