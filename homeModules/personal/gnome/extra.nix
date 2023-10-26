{ pkgs, lib, config, ... }:
let
  cfg = config.personal.gnome;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.tailscale-status
      gnomeExtensions.pip-on-top
      gnomeExtensions.caffeine
    ];

    dconf = {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          # `gnome-extensions list` for a list
          enabled-extensions = [
            "tailscale-status@maxgallup.github.com"
            "pip-on-top@rafostar.github.com"
            "caffeine@patapon.info"
          ];
        };
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
      };
    };
  };
}
