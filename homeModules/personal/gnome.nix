{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.personal.gnome;
  # Used for dconf values
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  options.personal.gnome = {
    enable = lib.mkEnableOption "gnome config";
  };

  config = lib.mkIf cfg.enable {
    personal.ghostty.enable = lib.mkDefault true;

    programs.gnome-shell = {
      enable = true;
      extensions = with pkgs; [
        { package = gnomeExtensions.alphabetical-app-grid; }
        { package = gnomeExtensions.appindicator; }
        { package = gnomeExtensions.tailscale-status; }
        { package = gnomeExtensions.pip-on-top; }
        { package = gnomeExtensions.caffeine; }
        { package = gnomeExtensions.system-monitor; }
        { package = gnomeExtensions.gsconnect; }
        { package = gnomeExtensions.clipboard-indicator; }
      ];
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/calendar" = {
          show-weekdate = true;
        };
        "org/gnome/desktop/interface" = {
          clock-format = "12h";
        };
        "org/gnome/system/location" = {
          enabled = true;
        };
        "org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
        "org/gnome/desktop/wm/keybindings" = {
          switch-to-workspace-left = [ "<Control><Super>Left" ];
          switch-to-workspace-right = [ "<Control><Super>Right" ];
        };
        "org/gnome/desktop/input-sources" = {
          sources = [
            (mkTuple [
              "xkb"
              "us"
            ])
            (mkTuple [
              "xkb"
              "ru"
            ])
          ];
          xkb-options = [ "caps:escape_shifted_capslock" ];
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          natural-scroll = true;
        };
        "org/gnome/desktop/peripherals/mouse" = {
          natural-scroll = true;
        };
        "org/gtk/gtk4/settings/file-chooser" = {
          show-hidden = true;
        };
        "org/gnome/nautilus/list-view" = {
          use-tree-view = true;
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
        };
        "org/gnome/desktop/interface" = {
          gtk-enable-primary-paste = false;
        };
      };
    };

    programs.git = {
      package = pkgs.gitFull;
      extraConfig.credential.helper = "libsecret";
    };
  };
}
