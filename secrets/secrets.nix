let
  keys = import ../keys.nix;
  hades_keyset = [ keys.hades ] ++ keys.trusted_users;
  iris_keyset = [ keys.iris ] ++ keys.trusted_users;
in {
  "traefik.env.age".publicKeys = [ keys.hades keys.iris keys.hermes ]
    ++ keys.trusted_users;
  "transmission.env.age".publicKeys = hades_keyset;
  "kanidm-password.age".publicKeys = hades_keyset;
  "audiobookshelf-client-secret.age".publicKeys = hades_keyset;
  "oauth2-proxy-client-secret.age".publicKeys = hades_keyset;
  "oauth2-proxy-config.age".publicKeys = hades_keyset;
  "sonarr-basic-auth.age".publicKeys = hades_keyset;
  "radarr-basic-auth.age".publicKeys = hades_keyset;
  "prowlarr-basic-auth.age".publicKeys = hades_keyset;
  "grafana-client-secret.age".publicKeys = hades_keyset;
  "homepage-environment.age".publicKeys = hades_keyset;
}
