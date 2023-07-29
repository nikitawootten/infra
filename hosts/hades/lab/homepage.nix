{ config, secrets, ... }:
let
  settings = {
    title = "Hades";
    theme = "dark";
    color = "slate";
    showStats = true;
  };
  settingsFile = builtins.toFile "homepage-settings.yaml" (builtins.toJSON settings);
  # Currently all service widgets that require secrets must be defined here
  # see https://github.com/benphelps/homepage/discussions/1713
  services = [
    {
      Infrastructure = [
        {
          Pandora = {
            icon = "pfsense.png";
            href = "https://pandora.${config.lib.lab.domain}";
            description = "pfSense Firewall";
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
    {
      Media = [
        {
          Hypnos = {
            icon = "jellyfin.png";
            href = "https://hypnos.${config.networking.hostName}.${config.lib.lab.domain}";
            description = "Jellyfin: Media server";
            server = "my-docker";
            container = "jellyfin";
            widget = {
              type = "jellyfin";
              url = "https://hypnos.${config.networking.hostName}.${config.lib.lab.domain}";
              key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
              enableBlocks = true;
              enableNowPlaying = true;
            };
          };
        }
        {
          Tartarus = {
            icon = "transmission.png";
            href = "https://tartarus.${config.networking.hostName}.${config.lib.lab.domain}/transmission";
            description = "Transmission: Download server";
            server = "my-docker";
            container = "transmission-ovpn";
            widget = {
              type = "transmission";
              url = "https://tartarus.${config.networking.hostName}.${config.lib.lab.domain}";
              rpcUrl = "/transmission/";
            };
          };
        }
        {
          Lachesis = {
            icon = "prowlarr.png";
            href = "https://lachesis.${config.networking.hostName}.${config.lib.lab.domain}";
            description = "Prowlarr: Indexer";
            server = "my-docker";
            container = "prowlarr";
            widget = {
              type = "prowlarr";
              url = "https://lachesis.${config.networking.hostName}.${config.lib.lab.domain}";
              key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
            };
          };
        }
        {
          Clotho = {
            icon = "sonarr.png";
            href = "https://clotho.${config.networking.hostName}.${config.lib.lab.domain}";
            description = "Sonarr: TV series management";
            server = "my-docker";
            container = "sonarr";
            widget = {
              type = "sonarr";
              url = "https://clotho.${config.networking.hostName}.${config.lib.lab.domain}";
              key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
            };
          };
        }
        {
          Atropos = {
            icon = "radarr.png";
            href = "https://atropos.${config.networking.hostName}.${config.lib.lab.domain}";
            description = "Radarr: TV series management";
            server = "my-docker";
            container = "radarr";
            widget = {
              type = "radarr";
              url = "https://atropos.${config.networking.hostName}.${config.lib.lab.domain}";
              key = "{{HOMEPAGE_VAR_RADARR_APIKEY}}";
            };
          };
        }
      ];
    }
  ];
  servicesFile = builtins.toFile "homepage-services.yaml" (builtins.toJSON services);
  bookmarks = [
    {
      Administration = [
        { Source = [ { icon = "github.png"; href = "https://github.com/nikitawootten/infra"; } ]; }
        { Tailscale = [ { abbr = "TS"; href = "https://login.tailscale.com/admin/machines/"; } ]; }
        { Cloudflare = [ { icon = "cloudflare.png"; href = "https://dash.cloudflare.com/"; } ]; }
      ];
    }
    {
      Development = [
        { CyberChef = [ { icon = "cyberchef.png"; href = "https://gchq.github.io/CyberChef/"; } ]; }
        { "Nix Options Search" = [ { abbr = "NS"; href = "https://search.nixos.org/packages"; } ]; }
        { "Arion Documentation" = [ { abbr = "AD"; href = "https://docs.hercules-ci.com/arion/"; } ]; }
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
      "homepage.href" = "https://${subdomain}.${config.networking.hostName}.${config.lib.lab.domain}";
      "homepage.icon" = icon;
    });

  age.secrets.homepage.file = secrets.homepage;

  virtualisation.arion.projects.lab.settings.services.homepage = {
    service = {
      container_name = "homepage";
      image = "ghcr.io/benphelps/homepage";
      ports = [ "3000:3000" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/backplane/applications/homepage/logs/:/config/logs/"
        "${settingsFile}:/config/settings.yaml"
        "${servicesFile}:/config/services.yaml"
        "${bookmarksFile}:/config/bookmarks.yaml"
        "${widgetsFile}:/config/widgets.yaml"
        "${dockerFile}:/config/docker.yaml"
      ];
      env_file = [ config.age.secrets.homepage.path ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "homepage";
        root = true;
      };
      useHostStore = true;
    };
  };
}
