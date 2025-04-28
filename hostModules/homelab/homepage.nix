{ lib, config, ... }:
let
  cfg = config.homelab.homepage;

  enableDefaultTrueOption = description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      inherit description;
    };

  priorityOption = lib.mkOption {
    type = lib.types.int;
    default = 10;
    description = "Sort priority (default 10)";
  };

  itemConfigType = lib.types.submodule {
    options = {
      enable = enableDefaultTrueOption "Enable item";
      priority = priorityOption;
      config = lib.mkOption {
        type = lib.types.attrs;
        description = "Item (service, widget, etc.) configuration";
        default = { };
      };
    };
  };

  itemGroupConfigType = lib.types.submodule {
    options = {
      enable = enableDefaultTrueOption "Enable group";
      priority = priorityOption;
      config = lib.mkOption {
        type = lib.types.attrsOf itemConfigType;
        description = "Item (services, bookmarks, etc.) group configuration";
        default = { };
      };
    };
  };

  priorityComparator = a: b: a.value.priority - b.value.priority > 0;
  sortByPriority = list: (builtins.sort priorityComparator list);

  toHomepageConfig = itemsConfig:
    let
      keys = builtins.attrNames itemsConfig;
      items = builtins.map (name: {
        inherit name;
        value = builtins.getAttr name itemsConfig;
      }) keys;
      sorted = sortByPriority items;
      filtered = builtins.filter (item: item.value.enable) sorted;
    in builtins.map (item: { "${item.name}" = item.value.config; }) filtered;

  toParentHomepageConfig = itemsConfig:
    let
      transformed = builtins.mapAttrs
        (name: item: item // { config = toHomepageConfig item.config; })
        itemsConfig;
    in toHomepageConfig transformed;
in {
  options.homelab.homepage = {
    enable = lib.mkEnableOption "Homepage dashboard";
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.domain;
      description = "Homepage domain";
    };
    services = lib.mkOption {
      type = lib.types.attrsOf itemGroupConfigType;
      default = { };
    };
  };

  # Inject a bit of declarative configuration for the homepage dashboard
  options.services.homepage-dashboard = {
    services-declarative = lib.mkOption {
      type = lib.types.attrsOf itemGroupConfigType;
      default = { };
    };
    bookmarks-declarative = lib.mkOption {
      type = lib.types.attrsOf itemGroupConfigType;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard =
      let service-cfg = config.services.homepage-dashboard;
      in {
        enable = true;
        services = toParentHomepageConfig service-cfg.services-declarative;
        bookmarks = toParentHomepageConfig service-cfg.bookmarks-declarative;
        allowedHosts = cfg.domain;
      };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/".proxyPass = "http://127.0.0.1:${
          toString config.services.homepage-dashboard.listenPort
        }";
    };
  };
}
