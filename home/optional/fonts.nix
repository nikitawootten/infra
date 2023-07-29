{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      monospace-font-name = "JetBrains Mono 10";
    };
  };
}
