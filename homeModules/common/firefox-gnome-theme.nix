{ lib, config, pkgs, ... }:
let
  repo = pkgs.fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "v114";
    sha256 = "sha256-o53fws/jwhLfxiYfTyYpKSGi61d5LHzGgSCkt3DNGRI=";
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
    };
  };
}
