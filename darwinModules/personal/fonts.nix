{ pkgs, lib, config, ... }:
let cfg = config.personal.fonts;
in {
  options.personal.fonts = { enable = lib.mkEnableOption "additional fonts"; };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableFontDir = true;
      fonts = with pkgs; [
        jetbrains-mono
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];
    };
  };
}
