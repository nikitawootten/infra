{ pkgs, lib, config, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  cfg = config.personal.gnome;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.pano
    ];
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "pano@elhan.io"
        ];
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

      "org/gnome/nautilus/list-view" = {
        "use-tree-view" = true;
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
      };
    };
  };
}
