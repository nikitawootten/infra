{ pkgs, lib, config, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  cfg = config.personal.gnome;
in {
  options.personal.gnome = {
    enablePaperWm = lib.mkEnableOption "PaperWM tiling extension";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # gnomeExtensions.pano
        gnomeExtensions.paperwm
      ];
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          # "pano@elhan.io"
        ] ++ lib.lists.optional cfg.enablePaperWm "paperwm@paperwm.github.com";
      };
      "org/gnome/desktop/wm/keybindings" =
        lib.attrsets.optionalAttrs (!cfg.enablePaperWm) {
          switch-to-workspace-left = [ "<Control><Super>Left" ];
          switch-to-workspace-right = [ "<Control><Super>Right" ];
        };
      "org/gnome/desktop/input-sources" = {
        sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ru" ]) ];
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        natural-scroll = true;
      };
      "org/gnome/desktop/peripherals/mouse" = { natural-scroll = false; };
      "org/gtk/gtk4/settings/file-chooser" = { show-hidden = true; };
      "org/gnome/nautilus/list-view" = { use-tree-view = true; };
      "org/gnome/mutter" = {
        edge-tiling = !cfg.enablePaperWm;
        dynamic-workspaces = true;
      };
      "org/gnome/shell/extensions/paperwm" = {
        show-workspace-indicator = false;
      };
    };
  };
}
