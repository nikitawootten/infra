{ config, lib, ... }:
let
  cfg = config.homelab.infra.oauth2-proxy;
  clientId = "oauth2-proxy";
  idp = let domain = config.homelab.infra.kanidm.domain;
  in {
    # Thanks to @griffi-gh for this snippet
    # Via https://github.com/girl-pp-ua/nixos-infra/blob/f06b49cc501d9e4cd7fb77345739a9efb5389deb/lib/idp.nix
    oidc_discovery_prefix = "https://${domain}/oauth2/openid/${clientId}";
    oidc_discovery =
      "https://${domain}/oauth2/openid/${clientId}/.well-known/openid-configuration";
    rfc8144_authorization_server_metadata =
      "https://${domain}/oauth2/openid/${clientId}/.well-known/oauth-authorization-server";
    user_auth = "https://${domain}/ui/oauth2";
    api_auth = "https://${domain}/oauth2/authorise";
    token_endpoint = "https://${domain}/oauth2/token";
    rfc7662_token_introspection = "https://${domain}/oauth2/token/introspect";
    rfc7662_token_revocation = "https://${domain}/oauth2/token/revoke";
    oidc_issuer_uri = "https://${domain}/oauth2/openid/${clientId}";
    oidc_user_info = "https://${domain}/oauth2/openid/${clientId}/userinfo";
    token_signing_public_key =
      "https://${domain}/oauth2/openid/${clientId}/public_key.jwk";
  };
in {
  options.homelab.infra.oauth2-proxy =
    config.lib.homelab.mkServiceOptionSet "OAuth2 Proxy" "oauth2" cfg // {
      # TODO: Can this be derived from     services.oauth2-proxy.nginx.virtualHosts.<name>.allowed_groups
      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Groups to create for OAuth2 Proxy services";
      };
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the OAuth2 Proxy client secret";
      };
      # NOTE: Unfortunately this contains redundant information to clientSecretFile
      # Example:
      # OAUTH2_PROXY_CLIENT_SECRET=<contents of clientSecretFile>
      # OAUTH2_PROXY_COOKIE_SECRET=<output of `openssl rand -base64 32 | tr -- '+/' '-_'`>
      keyFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing sensitive OAuth2 Proxy configuration";
      };
    };

  config = lib.mkIf cfg.enable {
    services.oauth2-proxy = {
      enable = true;
      keyFile = cfg.keyFile;
      reverseProxy = true;
      setXauthrequest = true;
      # redirectURL = "https://${cfg.domain}/oauth2/callback";

      provider = "oidc";
      clientID = clientId;
      oidcIssuerUrl = idp.oidc_issuer_uri;
      loginURL = idp.api_auth; # ui?
      redeemURL = idp.token_endpoint;
      validateURL = idp.rfc7662_token_introspection;
      profileURL = idp.oidc_user_info;

      email.domains = [ "*" ];
      scope = "openid email profile";

      extraConfig = {
        provider-display-name = "Kanidm";
        skip-provider-button = true;
        code-challenge-method = "S256";
        set-authorization-header = true;
        pass-access-token = true;
        skip-jwt-bearer-tokens = true;
        upstream = "static://202";
        whitelist-domain = ".${config.homelab.lan-domain}";
      };

      cookie.domain = config.homelab.lan-domain;
      nginx.domain = cfg.domain;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = config.services.oauth2-proxy.httpAddress;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header X-Scheme                $scheme;
          proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
        '';
      };
    };
    services.nginx.upstreams.${cfg.domain} = {
      servers = { "localhost:4180" = { }; };
    };

    services.kanidm.provision.groups =
      lib.genAttrs cfg.groups (_: { overwriteMembers = false; });
    services.kanidm.provision.systems.oauth2.${clientId} = {
      displayName = "OAuth2 Proxy";
      originUrl = [ "${cfg.url}/oauth2/callback" ];
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps = lib.genAttrs cfg.groups (_: [ "email" "openid" "profile" ]);
      claimMaps.groups = {
        joinType = "array";
        valuesByGroup = lib.genAttrs cfg.groups (group: [ group ]);
      };

    };

    systemd.services.oauth2-proxy.after =
      lib.optionals config.homelab.infra.kanidm.enable [
        "kanidm.service"
        "nginx.service"
      ];

    homelab.infra.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 9;
      config = {
        description = "SSO compatibility layer";
        href = cfg.url;
        icon = "oauth2-proxy.png";
        siteMonitor = cfg.url;
      };
    };
  };
}
