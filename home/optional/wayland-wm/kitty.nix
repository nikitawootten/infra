{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
  };
  home.sessionVariables.TERMINAL = "${pkgs.kitty}/bin/kitty";
}