{ pkgs, lib, config, ... }:
let
  cfg = config.personal.gnome;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.alphabetical-app-grid
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.night-theme-switcher
      # libadwaita lookalike for gtk3
      adw-gtk3
    ];

    dconf = {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "AlphabeticalAppGrid@stuarthayhurst"
            "appindicatorsupport@rgcjonas.gmail.com"
            "blur-my-shell@aunetx"
            "burn-my-windows@schneegans.github.com"
            "nightthemeswitcher@romainvigier.fr"
          ];
        };
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3";
        };
        "org/gnome/shell/extensions/nightthemeswitcher/time" = {
          nightthemeswitcher-ondemand-keybinding = [ "<Shift><Super>t" ];
        };
        "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
          enabled = true;
          day = "adw-gtk3";
          night = "adw-gtk3-dark";
        };
        "org/gnome/Console" = {
          theme = "auto";
        };
      };
    };
  };
}
