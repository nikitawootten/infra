{ pkgs, lib, config, ... }:
let cfg = config.personal.gnome;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.alphabetical-app-grid
      gnomeExtensions.appindicator
    ];

    dconf = {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "AlphabeticalAppGrid@stuarthayhurst"
            "appindicatorsupport@rgcjonas.gmail.com"
          ];
        };
      };
    };
  };
}
