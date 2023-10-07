{ pkgs, lib, config, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  cfg = config.personal.gnome;
in
{
  options.personal.gnome = {
    enable = lib.mkEnableOption "gnome config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.alphabetical-app-grid
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.pano
      gnomeExtensions.tailscale-status
      gnomeExtensions.pip-on-top
      # libadwaita lookalike for gtk3
      adw-gtk3
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          # `gnome-extensions list` for a list
          enabled-extensions = [
            "AlphabeticalAppGrid@stuarthayhurst"
            "appindicatorsupport@rgcjonas.gmail.com"
            "blur-my-shell@aunetx"
            "burn-my-windows@schneegans.github.com"
            "nightthemeswitcher@romainvigier.fr"
            "pano@elhan.io"
            "tailscale-status@maxgallup.github.com"
            "pip-on-top@rafostar.github.com"
          ];
        };
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3";
        };
        "org/gnome/desktop/calendar" = {
          show-weekdate = true;
        };
        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-left = [ "<Control><Super>Left" ];
          switch-to-workspace-right = [ "<Control><Super>Right" ];
        };
        "org/gnome/desktop/input-sources" = {
          sources = [
            (mkTuple [ "xkb" "us" ])
            (mkTuple [ "xkb" "ru" ])
          ];
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          natural-scroll = true;
        };
        "org/gnome/desktop/peripherals/mouse" = {
          natural-scroll = false;
        };
        "org/gtk/gtk4/settings/file-chooser" = {
          show-hidden = true;
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
        "org/gnome/nautilus/list-view" = {
          "use-tree-view" = true;
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
        };
      };
    };
  };
}
