{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.freshrss = {
    container_name = "freshrss";
    image = "freshrss/freshrss"; # Using Debian variant for OIDC
    # Additional fields configured through age secrets
    environment = {
      TZ = "America/New_York";
      OIDC_ENABLED = "1";
      OIDC_PROVIDER_METADATA_URL = "";
      OIDC_CLIENT_ID = "freshrss";
      # OIDC_CLIENT_SECRET = "";
      # OIDC_CLIENT_CRYPTO_KEY = "";
      OIDC_REMOTE_USER_CLAIM = "";
      # OIDC_SCOPES = "";
      OIDC_X_FORWARDED_HEADERS = "";
    };
    ports = [ "3005:80" ];
    volumes = [
      "${config.lib.lab.mkConfigDir "freshrss"}/data/:/var/www/FreshRSS/data"
      "${config.lib.lab.mkConfigDir "freshrss"}/extensions/:/var/www/FreshRSS/extensions"
    ];
    labels = config.lib.lab.mkTraefikLabels {
      name = "freshrss";
      subdomain = "morpheus";
    };
    restart = "unless-stopped";
  };
}