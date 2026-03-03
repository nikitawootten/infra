{ ... }:
{
  flake.modules.homeManager.misc-utils =
    { lib, pkgs, ... }:
    {
      programs = {
        gpg.enable = lib.mkDefault true;
        fzf.enable = lib.mkDefault true;
        zoxide = {
          enable = lib.mkDefault true;
          options = [ "--cmd cd" ];
        };
        htop.enable = lib.mkDefault true;
        btop.enable = lib.mkDefault true;
        jq.enable = lib.mkDefault true;
        nix-index.enable = lib.mkDefault true;
        nix-index-database.comma.enable = lib.mkDefault true;
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
        inetutils
        dnsutils
      ];
    };
}
