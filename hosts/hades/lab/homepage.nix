{ config, hostname, ... }:
let
  settings = {
    title = "Hades";
    theme = "dark";
    color = "slate";
    showStats = true;
  };
  settingsFile = builtins.toFile "homepage-settings.yaml" (builtins.toJSON settings);
  services = [
    {
      "Infrastructure" = [
        {
          "Pandora" = {
            icon = "pfsense.png";
            href = "https://pandora.arpa.nikita.computer";
            description = "pfSense Router";
            # TODO set up pfSense API
            # widget = {
            #   type = "pfsense";
            #   url = "https://pandora.arpa.nikita.computer";
            #   username = "";
            #   password = "";
            #   wan = "WAN";
            # };
          };
        }
      ];
    }
  ];
  servicesFile = builtins.toFile "homepage-services.yaml" (builtins.toJSON services);
  bookmarks = [
    {
      Developer = [
        {
          Tailscale = [
            {
              abbr = "TS";
              href = "https://login.tailscale.com/admin/machines/";
            }
          ];
        }
      ];
    }
  ];
  bookmarksFile = builtins.toFile "homepage-bookmarks.yaml" (builtins.toJSON bookmarks);
  widgets = [
    {
      resources = {
        cpu = true;
        memory = true;
        cputemp = true;
        uptime = true;
        units = "imperial";
        disk = "/";
        label = "system";
      };
    }
    {
      search = {
        provider = "duckduckgo";
        target = "_blank";
      };
    }
  ];
  widgetsFile = builtins.toFile "homepage-widgets.yaml" (builtins.toJSON widgets);
  docker = {
    my-docker.socket = "/var/run/docker.sock";
  };
  dockerFile = builtins.toFile "homepage-docker.yaml" (builtins.toJSON docker);
in
{
  lib.lab.mkHomepageLabels = options: (
    let
      name = options.name;
      description = options.description;
      group = options.group;
      subdomain = options.subdomain;
      icon = options.icon;
    in
    {
      "homepage.name" = name;
      "homepage.description" = description;
      "homepage.group" = group;
      "homepage.href" = "https://${subdomain}.${hostname}.${config.lib.lab.domain}";
      "homepage.icon" = icon;
    });

  virtualisation.arion.projects.lab.settings.services.homepage = {
    service = {
      container_name = "homepage";
      image = "ghcr.io/benphelps/homepage";
      ports = [
        "3000:3000"
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/backplane/applications/homepage/logs/:/config/logs/"
        "${settingsFile}:/config/settings.yaml"
        "${servicesFile}:/config/services.yaml"
        "${bookmarksFile}:/config/bookmarks.yaml"
        "${widgetsFile}:/config/widgets.yaml"
        "${dockerFile}:/config/docker.yaml"
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "homepage";
        root = true;
      };
      useHostStore = true;
    };
  };
}
