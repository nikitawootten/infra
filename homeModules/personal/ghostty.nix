{ config, lib, ... }:
let
  cfg = config.personal.ghostty;
in
{
  options.personal.ghostty = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "ghostty.desktop"
        ];
      };
    };
  };
}
