{ lib, config, ...}:
let
  cfg = config.homelab.auth;
in
{
  imports = [
    ./keycloak.nix
  ];

  options.homelab.auth = {
    enable = lib.mkEnableOption "Enable auth stack";
    homepageCategory = lib.mkOption {
      type = lib.types.str;
      default = "Auth";
      description = "Homepage category for the auth stack";
    };
    homepageConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Homepage configuration for the auth stack";
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.auth.keycloak.enable = true;

    services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
      priority = lib.mkDefault 6;
      config = cfg.homepageConfig;
    };
  };
}
