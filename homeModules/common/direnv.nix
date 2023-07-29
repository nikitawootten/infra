{ lib, config, devenv, system, ... }:
let
  cfg = config.personal.direnv;
in
{
  options.personal.direnv = {
    enable = lib.mkEnableOption "direnv config";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    home.packages = [
      devenv.packages.${system}.devenv
    ];
    programs.git.ignores = [
      ".direnv"
    ];
  };
}
