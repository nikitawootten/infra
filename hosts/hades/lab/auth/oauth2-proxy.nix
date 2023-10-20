{ secrets, config, ... }:
let
  subdomain = "oauth";
in
{
  age.secrets.oauth2-proxy.file = secrets.oauth2-proxy;

  # Note to self: Web origins may have to be set to a wildcard?

  virtualisation.arion.projects.lab.settings.services.oauth2-proxy = {
    service = {
      container_name = "oauth2-proxy";
      image = "quay.io/oauth2-proxy/oauth2-proxy";
      environment = {
        # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#keycloak-oidc-auth-provider
        OAUTH2_PROXY_COOKIE_DOMAINS = config.personal.lab.domain;
        OAUTH2_PROXY_HTTP_ADDRESS = ":3002";
        OAUTH2_PROXY_PROVIDER = "keycloak-oidc";
        OAUTH2_PROXY_CLIENT_ID = "oauth2-proxy";
        OAUTH2_PROXY_REDIRECT_URL = "https://${config.lib.lab.mkServiceSubdomain "oauth"}/oauth2/callback";
        OAUTH2_PROXY_OIDC_ISSUER_URL = "https://${config.lib.lab.mkServiceSubdomain "cerberus"}/realms/master";
        OAUTH2_PROXY_EMAIL_DOMAINS = "*";
        OAUTH2_PROXY_SCOPE = "openid email";
        # OAUTH2_PROXY_CODE_CHALLENGE_METHOD = "S256";
        # OAUTH2_PROXY_COOKIE_SECRET = "";
        # OAUTH2_PROXY_CLIENT_SECRET = "";
        # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/#forwardauth-with-static-upstreams-configuration
        OAUTH2_PROXY_UPSTREAMS = "static://202";
        OAUTH2_PROXY_REVERSE_PROXY = "true";
        # Traefik uses the "X-Forwarded-For" header to pass the client's IP address to oauth2-proxy
        OAUTH2_PROXY_REAL_CLIENT_IP_HEADER = "X-Forwarded-For";
      };
      env_file = [
        config.age.secrets.oauth2-proxy.path
      ];
      ports = [ "3002:3002" ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "oauth2-proxy";
        inherit subdomain;
        middleware = "auth-headers@file";
      } // config.lib.lab.mkHomepageLabels {
        name = "OAuth2 Proxy";
        description = "Traefik ForwardAuth Provider";
        group = "Infrastructure";
        inherit subdomain;
        icon = "https://oauth2-proxy.github.io/oauth2-proxy/img/logos/OAuth2_Proxy_icon.svg";
      };
      depends_on = [ "keycloak" ];
      restart = "unless-stopped";
    };
  };
}
