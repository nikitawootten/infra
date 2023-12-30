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
        OIDC_ENABLED = "1";
        OIDC_PROVIDER_METADATA_URL = "https://${config.lib.lab.mkServiceSubdomain "authentik"}/application/o/freshrss/.well-known/openid-configuration";
        OIDC_X_FORWARDED_HEADERS = "X-Forwarded-Port X-Forwarded-Proto X-Forwarded-Host";
        OIDC_SCOPES = "openid email profile";
        # # Defined in Age secret:
        # OIDC_CLIENT_ID = "freshrss";
        # OIDC_CLIENT_SECRET = "";
        CRON_MIN = "0,30";
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
        subdomain = "freshrss";
      };
      restart = "unless-stopped";
    };
  };

  personal.lab.homepage.media-services = [
    {
      FreshRSS = {
        icon = "freshrss.png";
        href = "https://${config.lib.lab.mkServiceSubdomain "freshrss"}";
        description = "Freshrss: RSS Reader";
        server = "my-docker";
        container = "freshrss";
      };
    }
  ];
}
