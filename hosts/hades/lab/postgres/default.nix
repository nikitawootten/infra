{ secrets, config, ... }:
{
  age.secrets.postgres.file = secrets.postgres;

  virtualisation.arion.projects.lab.settings.services.posgress= {
    service = {
      container_name = "postgres";
      image = "postgres";
      environment = {
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      volumes = [
        "/backplane/applications/postgres:/var/lib/postgresql/data"
        "${./init-dbs.sh}:/docker-entrypoint-initdb.d/init-dbs.sh"
      ];
      env_file = [
        config.age.secrets.keycloak.path
        config.age.secrets.postgres.path
      ];
      restart = "unless-stopped";
    };  
  };
}