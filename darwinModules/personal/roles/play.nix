{ config, lib, ... }:
let cfg = config.personal.roles.play;
in {
  options.personal.roles.play = {
    enable = lib.mkEnableOption "Gaming related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [{ personal.roles.play.enable = true; }];

    homebrew.casks = [ "steam" "prismLauncher" ];
  };
}
