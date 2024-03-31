{ lib, config, ... }:
let
  cfg = config.homelab.observability;
in
{
  imports = [
    ./grafana.nix
    ./prometheus.nix
    ./loki.nix
  ];

  options.homelab.observability = {
    enable = lib.mkEnableOption "Enable basic observability stack";
    homepageCategory = lib.mkOption {
      type = lib.types.str;
      default = "Observability";
      description = "Homepage category for the observability stack";
    };
    homepageConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Homepage configuration for the observability stack";
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.observability.grafana.enable = true;
    homelab.observability.prometheus.enable = true;
    homelab.observability.loki.enable = true;

    services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
      priority = lib.mkDefault 5;
      config = cfg.homepageConfig;
    };
  };
}
