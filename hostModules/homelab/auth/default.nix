{ lib, config, ... }:
let cfg = config.homelab.auth;
in {
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
      default = { };
    };
  };

  imports = [ ./kanidm.nix ];

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard.services-declarative.${cfg.homepageCategory} = {
      priority = lib.mkDefault 3;
      config = cfg.homepageConfig;
    };

    homelab.auth.kanidm.enable = lib.mkDefault true;
  };
}
