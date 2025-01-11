{ pkgs, lib, config, ... }:
let cfg = config.personal.fonts;
in {
  options.personal.fonts = { enable = lib.mkEnableOption "additional fonts"; };

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        nerd-fonts.jetbrains-mono
      ];
    };
  };
}
