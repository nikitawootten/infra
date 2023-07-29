{ secrets, config, ... }:
{
  age.secrets.keycloak.file = secrets.keycloak;

  virtualisation.arion.projects.lab.settings.services.keycloak = {
    service = {
      container_name = "keycloak";
      image = "quay.io/keycloak/keycloak";

      command = "start-dev";

      environment = {
        KC_HEALTH_ENABLED = "true";
        KC_PROXY = "edge";
        KC_HOSTNAME_STRICT = "false";
        KC_DB = "postgres";
        KC_DB_URL = "jdbc:postgresql://postgres/keycloak";
        KC_DB_SCHEMA = "public";
      };
      env_file = [
        config.age.secrets.keycloak.path
      ];
      ports = [ "3001:8080" ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "keycloak";
        subdomain = "cerberus";
      } // config.lib.lab.mkHomepageLabels {
        name = "Cerberus";
        description = "Keycloak: Authentication server";
        group = "Infrastructure";
        subdomain = "cerberus";
        icon = "keycloak.png";
      };
      restart = "unless-stopped";
    };
  };
}