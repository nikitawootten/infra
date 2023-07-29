{ secrets, config, ... }:
{
  age.secrets.watchtower.file = secrets.watchtower;

  virtualisation.arion.projects.lab.settings.services.watchtower = {
    service = {
      container_name = "watchtower";
      image = "containrrr/watchtower";
      environment = {
        WATCHTOWER_HTTP_API_METRICS = "true";
      };
      env_file = [ config.age.secrets.watchtower.path ];
      ports = [ "3004:8080" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}