{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.personal.fonts;
in
{
  options.personal.fonts = {
    enable = lib.mkEnableOption "additional fonts";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        monospace-font-name = lib.mkDefault "JetBrains Mono 10";
      };
    };
  };
}
