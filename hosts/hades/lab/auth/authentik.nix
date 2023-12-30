{ secrets, config, ... }:
let
  config-dir = config.lib.lab.mkConfigDir "authentik";
in
{
  age.secrets.authentik-pg.file = secrets.authentik-pg;
  age.secrets.authentik.file = secrets.authentik;

  virtualisation.arion.projects.auth.settings = {
    services = {
      postgresql.service = {
        image = "docker.io/library/postgres:12-alpine";
        restart = "unless-stopped";
        healthcheck = {
          test = [
            "CMD-SHELL"
            "pg_isready -d $\${POSTGRES_DB} -U $\${POSTGRES_USER}"
          ];
          start_period = "20s";
          interval = "30s";
          retries = 5;
          timeout = "5s";
        };
        volumes = [ "${config-dir}/database:/var/lib/postgresql/data" ];
        environment = {
          # Password set by age secret
          # POSTGRES_PASSWORD = "\${PG_PASS:?database password required}";
          POSTGRES_USER = "\${PG_USER:-authentik}";
          POSTGRES_DB = "\${PG_DB:-authentik}";
        };
        env_file = [
          config.age.secrets.authentik-pg.path
        ];
      };
      redis.service = {
        image = "docker.io/library/redis:alpine";
        command = "--save 60 1 --loglevel warning";
        restart = "unless-stopped";
        healthcheck = {
          test = [ "CMD-SHELL" "redis-cli ping | grep PONG" ];
          start_period = "20s";
          interval = "30s";
          retries = 5;
          timeout = "3s";
        };
        volumes = [ "${config-dir}/redis:/data" ];
      };
      server.service = {
        image =
          "\${AUTHENTIK_IMAGE:-ghcr.io/goauthentik/server}:\${AUTHENTIK_TAG:-2023.10.5}";
        restart = "unless-stopped";
        command = "server";
        environment = {
          AUTHENTIK_COOKIE_DOMAIN = config.personal.lab.domain;
          AUTHENTIK_REDIS__HOST = "redis";
          AUTHENTIK_POSTGRESQL__HOST = "postgresql";
          AUTHENTIK_POSTGRESQL__USER = "\${PG_USER:-authentik}";
          AUTHENTIK_POSTGRESQL__NAME = "\${PG_DB:-authentik}";
          # Password set by age secret
          # AUTHENTIK_POSTGRESQL__PASSWORD = "\${PG_PASS}";
        };
        volumes = [
          "${config-dir}/media:/media"
          "${config-dir}/custom-templates:/templates"
        ];
        env_file = [
          config.age.secrets.authentik.path
        ];
        ports = [
          "\${COMPOSE_PORT_HTTP:-9000}:9000"
          "\${COMPOSE_PORT_HTTPS:-9443}:9443"
        ];
        depends_on = [ "postgresql" "redis" ];
        networks = [
          "default"
          "lab"
        ];
        labels = config.lib.lab.mkTraefikLabels {
          name = "authentik";
          subdomain = "authentik";
        } // config.lib.lab.mkHomepageLabels {
          name = "Authentik";
          description = "Authentik Identity Provider";
          group = "Infrastructure";
          subdomain = "authentik";
          icon = "authentik.png";
        } // {
          "traefik.docker.network" = "lab";
        };
      };
      worker.service = {
        image =
          "\${AUTHENTIK_IMAGE:-ghcr.io/goauthentik/server}:\${AUTHENTIK_TAG:-2023.10.5}";
        restart = "unless-stopped";
        command = "worker";
        environment = {
          AUTHENTIK_REDIS__HOST = "redis";
          AUTHENTIK_POSTGRESQL__HOST = "postgresql";
          AUTHENTIK_POSTGRESQL__USER = "\${PG_USER:-authentik}";
          AUTHENTIK_POSTGRESQL__NAME = "\${PG_DB:-authentik}";
          # Password set by age secret
          # AUTHENTIK_POSTGRESQL__PASSWORD = "\${PG_PASS}";
        };
        user = "root";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${config-dir}/media:/media"
          "${config-dir}/certs:/certs"
          "${config-dir}/templates:/templates"
        ];
        env_file = [
          config.age.secrets.authentik.path
        ];
        depends_on = [ "postgresql" "redis" ];
      };
    };

    networks.lab.external = true;
  };
}
