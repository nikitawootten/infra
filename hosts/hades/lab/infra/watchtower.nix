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

  personal.lab.homepage.infrastructure-services = [
    {
      Watchtower = {
        icon = "watchtower.png";
        description = "Container update manager";
        server = "my-docker";
        container = "watchtower";
        widget = {
          type = "watchtower";
          url = "http://watchtower:3004";
          key = "{{HOMEPAGE_VAR_WATCHTOWER_APIKEY}}";
        };
      };
    }
  ];
}