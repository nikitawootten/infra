{ self, ... }:
{
  flake.modules.nixos.homelab-infra =
    { lib, config, ... }:
    let
      cfg = config.homelab.infra;
    in
    {
      options.homelab.infra = {
        enable = lib.mkEnableOption "Enable infrastructure stack";
        homepageCategory = lib.mkOption {
          type = lib.types.str;
          default = "Infrastructure";
          description = "Homepage category for the infra stack";
        };
        homepageConfig = lib.mkOption {
          type = lib.types.attrs;
          description = "Homepage configuration for the infra stack";
          default = { };
        };
      };

      imports = [
        self.modules.nixos.homelab-kanidm
        self.modules.nixos.homelab-oauth2-proxy
        self.modules.nixos.homelab-grafana
        self.modules.nixos.homelab-prometheus
        self.modules.nixos.homelab-loki
      ];

      config = lib.mkIf cfg.enable {
        services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
          priority = lib.mkDefault 6;
          config = cfg.homepageConfig;
        };

        homelab.infra.kanidm.enable = lib.mkDefault true;
        homelab.infra.oauth2-proxy.enable = lib.mkDefault true;
        homelab.infra.grafana.enable = true;
        homelab.infra.prometheus.enable = true;
        homelab.infra.loki.enable = true;

        homelab.infra.homepageConfig."Pandora" = {
          priority = lib.mkDefault 15;
          config = {
            description = "Ubiquiti Cloud Gateway Ultra";
            href = "https://192.168.1.1";
            icon = "ubiquiti-unifi.png";
          };
        };
      };
    };
}
