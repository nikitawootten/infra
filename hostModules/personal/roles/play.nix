{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.play;
in {
  options.personal.roles.play = {
    enable = lib.mkEnableOption "Play related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [{ personal.roles.play.enable = true; }];

    nixpkgs.config.allowUnfree = true;
    programs.steam.enable = true;

    # Thunder store client
    environment.systemPackages = with pkgs; [ r2modman ];
  };
}
