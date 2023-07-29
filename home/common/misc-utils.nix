{ lib, pkgs, nix-index-database, ... }:
{
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  programs = {
    fzf.enable = lib.mkDefault true;
    htop.enable = lib.mkDefault true;
    jq.enable = lib.mkDefault true;
    nix-index.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
    gnumake
    wget
    file
    tree
    parallel
    yq
    qrencode # useful for terminal -> phone communication
  ];
}
