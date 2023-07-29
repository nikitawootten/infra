{ lib, config, secrets, ... }:
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
            href = "https://pandora.${config.personal.lab.base-domain}";
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
            href = "https://${config.lib.lab.mkServiceSubdomain "hypnos"}";
            description = "Jellyfin: Media server";
            server = "my-docker";
            container = "jellyfin";
            widget = {
              type = "jellyfin";
              url = "https://${config.lib.lab.mkServiceSubdomain "hypnos"}";
              key = "{{HOMEPAGE_VAR_JELLYFIN_APIKEY}}";
              enableBlocks = true;
              enableNowPlaying = true;
            };
          };
        }
        {
          Tartarus = {
            icon = "transmission.png";
            href = "https://${config.lib.lab.mkServiceSubdomain "tartarus"}/transmission";
            description = "Transmission: Download server";
            server = "my-docker";
            container = "transmission-ovpn";
            widget = {
              type = "transmission";
              url = "http://transmission-ovpn:9091";
              rpcUrl = "/transmission/";
            };
          };
        }
        {
          Lachesis = {
            icon = "prowlarr.png";
            href = "https://${config.lib.lab.mkServiceSubdomain "lachesis"}";
            description = "Prowlarr: Indexer";
            server = "my-docker";
            container = "prowlarr";
            widget = {
              type = "prowlarr";
              url = "http://prowlarr:9696";
              key = "{{HOMEPAGE_VAR_PROWLARR_APIKEY}}";
            };
          };
        }
        {
          Clotho = {
            icon = "sonarr.png";
            href = "https://${config.lib.lab.mkServiceSubdomain "clotho"}";
            description = "Sonarr: TV series management";
            server = "my-docker";
            container = "sonarr";
            widget = {
              type = "sonarr";
              url = "http://sonarr:8989";
              key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
            };
          };
        }
        {
          Atropos = {
            icon = "radarr.png";
            href = "https://${config.lib.lab.mkServiceSubdomain "atropos"}";
            description = "Radarr: TV series management";
            server = "my-docker";
            container = "radarr";
            widget = {
              type = "radarr";
              url = "http://radarr:7878";
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
      icon = options.icon;
    in
    {
      "homepage.name" = name;
      "homepage.description" = description;
      "homepage.group" = group;
      "homepage.icon" = icon;
    } // lib.attrsets.optionalAttrs (builtins.hasAttr "subdomain" options) {
      "homepage.href" = "https://${config.lib.lab.mkServiceSubdomain options.subdomain}";
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
    };
  };
}
