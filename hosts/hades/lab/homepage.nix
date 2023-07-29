{ lib, config, secrets, ... }:
let
  cfg = config.personal.lab.homepage;
in
{
  # Currently all service widgets that require secrets must be defined here
  # see https://github.com/benphelps/homepage/discussions/1713
  # TODO either submit the appropriate path upstream or migrate to a submodule system
  options.personal.lab.homepage = {
    infrastructure-services = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Services to add to the infrastructure column";
      default = [];
    };
    home-services = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Services to add to the infrastructure column";
      default = [];
    };
    media-services = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Services to add to the infrastructure column";
      default = [];
    };
    # TODO add more options for bookmarks
  };

  config = let
    settings = {
      title = "Hades";
      theme = "dark";
      color = "slate";
      showStats = true;
    };
    settingsFile = builtins.toFile "homepage-settings.yaml" (builtins.toJSON settings);
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

    services = [
      { Infrastructure = cfg.infrastructure-services; }
      { Home = cfg.home-services; }
      { Media = cfg.media-services; }
    ];
    servicesFile = builtins.toFile "homepage-services.yaml" (builtins.toJSON services);
  in {
    age.secrets.homepage.file = secrets.homepage;

    virtualisation.arion.projects.lab.settings.services.homepage = {
      service = {
        container_name = "homepage";
        image = "ghcr.io/benphelps/homepage";
        ports = [ "3000:3000" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "${config.lib.lab.mkConfigDir "homepage"}/logs/:/config/logs/"
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

    # Make docker labels for a homepage configuration
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
  };
}
