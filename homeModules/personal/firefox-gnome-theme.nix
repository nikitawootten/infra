{ lib, config, pkgs, ... }:
let
  repo = pkgs.fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "v121";
    sha256 = "sha256-M+Cw6vh7xCDmIhyVuEPNmaNVUwpmdFQq8zlsXZTKees=";
  };
  profile = "default";
  cfg = config.personal.firefox.gnome-theme;
in
{
  options.personal.firefox.gnome-theme = {
    enable = lib.mkEnableOption "firefox gnome theme";
  };

  config = lib.mkIf cfg.enable {
    home.file.firefox-gnome-theme = {
      enable = true;
      source = repo;
      recursive = true;
      target = ".mozilla/firefox/${profile}/chrome/firefox-gnome-theme";
    };
    programs.firefox.profiles.${profile} = {
      extraConfig = ''
        ${builtins.readFile "${repo}/configuration/user.js"}
      '';

      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';

      userContent = ''
        @import "firefox-gnome-theme/userContent.css;
      '';

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
    };
  };
}
