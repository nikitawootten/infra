{ secrets, config, ... }:
{
  age.secrets.postgres.file = secrets.postgres;

  virtualisation.arion.projects.lab.settings.services.postgres = {
    service = {
      container_name = "postgres";
      image = "postgres";
      environment = {
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      volumes = [
        "${config.lib.lab.mkConfigDir "postgres"}/:/var/lib/postgresql/data"
        "${./init-dbs.sh}:/docker-entrypoint-initdb.d/init-dbs.sh"
      ];
      env_file = [
        config.age.secrets.keycloak.path
        config.age.secrets.postgres.path
      ];
      labels = config.lib.lab.mkHomepageLabels {
        name = "Postgres";
        description = "Postgres Database";
        group = "Infrastructure";
        icon = "postgres.png";
      };
      restart = "unless-stopped";
    };  
  };
}