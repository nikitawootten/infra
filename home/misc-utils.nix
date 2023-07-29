{ lib, pkgs, ... }:
{
  programs = {
    bat = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
      ];
    };
    fzf.enable = lib.mkDefault true;
    htop.enable = lib.mkDefault true;
    jq.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; [
    tree
    yq
    qrencode # useful for terminal -> phone communication
  ];
}
