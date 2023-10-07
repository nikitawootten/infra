{ lib, config, pkgs, ... }:
let
  cfg = config.personal.misc-utils;
in
{
  options.personal.misc-utils = {
    enable = lib.mkEnableOption "misc utilities";
  };

  config = lib.mkIf cfg.enable {
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
      binutils
    ];
  };
}
