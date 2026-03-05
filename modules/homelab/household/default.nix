{ self, ... }:
{
  flake.nixosModules.homelab-household =
    { lib, config, ... }:
    let
      cfg = config.homelab.household;
    in
    {
      options.homelab.household = {
        enable = lib.mkEnableOption "Enable household stack";
        homepageCategory = lib.mkOption {
          type = lib.types.str;
          default = "Personal & Productivity";
          description = "Homepage category for the household stack";
        };
        homepageConfig = lib.mkOption {
          type = lib.types.attrs;
          description = "Homepage configuration for the household stack";
          default = { };
        };
      };

      imports = [
        self.nixosModules.homelab-actual
        self.nixosModules.homelab-changedetection-io
        self.nixosModules.homelab-mealie
        self.nixosModules.homelab-immich
      ];

      config = lib.mkIf cfg.enable {
        services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
          priority = lib.mkDefault 7;
          config = cfg.homepageConfig;
        };

        homelab.household.actual.enable = lib.mkDefault true;
        homelab.household.changedetection-io.enable = lib.mkDefault true;
        homelab.household.mealie.enable = lib.mkDefault true;
        homelab.household.immich.enable = lib.mkDefault true;
      };
    };
}
