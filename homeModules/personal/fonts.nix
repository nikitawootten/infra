{ pkgs, lib, config, ... }:
let cfg = config.personal.fonts;
in {
  options.personal.fonts = { enable = lib.mkEnableOption "additional fonts"; };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        monospace-font-name = "JetBrains Mono 10";
      };
    };
  };
}
