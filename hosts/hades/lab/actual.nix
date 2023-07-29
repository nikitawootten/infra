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
        "/backplane/applications/actual/:/data"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "actual";
        subdomain = "plutus";
      } // config.lib.lab.mkHomepageLabels {
        name = "Plutus";
        description = "Budget management with Actual";
        group = "Home";
        subdomain = "plutus";
        icon = "actual.png";
      };
      useHostStore = true;
    };
  };
}