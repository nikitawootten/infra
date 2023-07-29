{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    jetbrains-mono
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      monospace-font-name = "JetBrains Mono 10";
    };
  };
}
