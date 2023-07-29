{ lib, pkgs, ... }:
{
  allowedUnfreePackagesRegexs = [ "burpsuite" ];
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    nmap
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    burpsuite
  ]);
  # Fix font rendering for burpsuite
  home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
}
