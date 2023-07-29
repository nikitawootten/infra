{ pkgs, ... }:
let
  repo = pkgs.fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "v114";
    sha256 = "sha256-o53fws/jwhLfxiYfTyYpKSGi61d5LHzGgSCkt3DNGRI=";
  };
  profile = "default";
in
{
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
}
