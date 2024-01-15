{ config, ... }:
{
  virtualisation.arion.projects.lab.settings.services.actual = {
    service = {
      container_name = "actual";
      image = "ghcr.io/actualbudget/actual-server";
      ports = [
        "5006:5006"
      ];
      volumes = [
        "${config.lib.lab.mkConfigDir "actual"}/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "actual";
        subdomain = "actual";
        forwardAuth = true;
      } // config.lib.lab.mkHomepageLabels {
        name = "Actual";
        description = "Actual: Budget management";
        group = "Home";
        subdomain = "actual";
        icon = "actual.png";
      };
    };
  };
}
