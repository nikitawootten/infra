{ pkgs, lib, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  home.packages = with pkgs; [
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.night-theme-switcher
    gnomeExtensions.pano
    gnomeExtensions.tailscale-status
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
          (mkTuple ["xkb" "us"])
          (mkTuple ["xkb" "ru"])
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
    };
  };
}
