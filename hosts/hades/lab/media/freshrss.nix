{ secrets, config, ... }:
{
  age.secrets.freshrss.file = secrets.freshrss;

  virtualisation.arion.projects.lab.settings.services.freshrss = {
    service = {
      container_name = "freshrss";
      image = "freshrss/freshrss"; # Using Debian variant for OIDC
      # Additional fields configured through age secrets
      environment = {
        TZ = "America/New_York";
        # TODO restrict traefik to a predictable address?
        TRUSTED_PROXY = "172.17.0.0/16";
        # OIDC_ENABLED = "1";
        # OIDC_PROVIDER_METADATA_URL = "https://${config.lib.lab.mkServiceSubdomain "cerberus"}/realms/master/.well-known/openid-configuration";
        # OIDC_CLIENT_ID = "freshrss";
        # OIDC_X_FORWARDED_HEADERS = "X-Forwarded-For X-Forwarded-Port X-Forwarded-Proto";
        # # Defined in Age secret:
        # # OIDC_CLIENT_SECRET = "";
        # # head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32
        # # OIDC_CLIENT_CRYPTO_KEY = "";
        # # Left at default value:
        # # OIDC_REMOTE_USER_CLAIM = "";
        # # OIDC_SCOPES = "";
      };
      env_file = [
        config.age.secrets.freshrss.path
      ];
      ports = [ "3005:80" ];
      volumes = [
        "${config.lib.lab.mkConfigDir "freshrss"}/data/:/var/www/FreshRSS/data"
        "${config.lib.lab.mkConfigDir "freshrss"}/extensions/:/var/www/FreshRSS/extensions"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "freshrss";
        subdomain = "nike";
        # forwardAuth = true;
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      Nike = {
        icon = "freshrss.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "nike"}";
        description = "Freshrss: RSS Reader";
        server = "my-docker";
        container = "freshrss";
      };
    }
  ];
}