{ config, lib, ... }:
let cfg = config.personal.rancher;
in {
  options.personal.rancher = {
    enable = lib.mkEnableOption "Enable Rancher desktop";
  };

  config = lib.mkIf cfg.enable {
    homebrew.enable = lib.mkDefault true;
    homebrew.casks = [ "rancher" ];
    home-manager.sharedModules = [{ home.sessionPath = [ "$HOME/.rd/bin" ]; }];
  };
}
