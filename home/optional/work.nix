{ lib, pkgs, ... }:
let
  brewPath = "/opt/homebrew/bin/brew";
  envSetup = shell: ''eval "$(${brewPath} shellenv ${shell})"'';
in
{
  programs.git.userEmail = lib.mkForce "nikita.wootten@nist.gov";
  home.packages = with pkgs; [
    awscli2
    utm
    kitty
    rectangle
  ];

  # NOTE: this module does NOT install homebrew

  programs.bash.profileExtra = ''
    ${envSetup "bash"}
  '';

  programs.zsh.profileExtra = ''
    ${envSetup "zsh"}
  '';
}
