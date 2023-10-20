{ pkgs, lib, config, ... }:
let
  mkTuple = lib.hm.gvariant.mkTuple;
  cfg = config.personal.gnome;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.tailscale-status
      gnomeExtensions.pip-on-top
    ];

    dconf = {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          # `gnome-extensions list` for a list
          enabled-extensions = [
            "tailscale-status@maxgallup.github.com"
            "pip-on-top@rafostar.github.com"
          ];
        };
        "org/gnome/desktop/calendar" = {
          show-weekdate = true;
        };
        "/org/gtk/settings/file-chooser" = {
          clock-format = "12h";
        };
        "/org/gnome/system/location" = {
          enabled = true;
        };
        "/org/gnome/desktop/datetime" = {
          automatic-timezone = true;
        };
      };
    };
  };
}
