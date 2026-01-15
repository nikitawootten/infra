{ config, lib, ... }:
let
  cfg = config.personal.roles.security;
in
{
  options.personal.roles.security = {
    enable = lib.mkEnableOption "Security tools";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [ { personal.roles.security.enable = true; } ];

    homebrew.brews = [ "ipsw" ];
    homebrew.casks = [ "wireshark-app" ];
  };
}
