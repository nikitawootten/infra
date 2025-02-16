{ pkgs, config, lib, ... }:
let cfg = config.personal.steam;
in {
  options.personal.steam = {
    enable = lib.mkEnableOption "steam configuration";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    programs.steam.enable = true;

    # Thunder store client
    environment.systemPackages = with pkgs; [ r2modman ];
  };
}
