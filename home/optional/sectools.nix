{ lib, pkgs, ... }:
{
  # Currently burpsuite does not work with allowUnfreePredicate for some reason
  # see https://github.com/NixOS/nixpkgs/issues/238466
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "burpsuite"
  ];
  nixpkgs.config.allowUnfree = true; # TODO remove when fixed?
  home.packages = with pkgs; [
    nmap
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    burpsuite
  ]);
  # Fix font rendering for burpsuite
  home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
}