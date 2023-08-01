{ lib, config, devenv ? null, pkgs, ... }:
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
    programs.git.ignores = [
      ".direnv"
    ];
    home.packages = lib.lists.optionals (!(builtins.isNull devenv)) [
      devenv.packages.${pkgs.system}.devenv
    ];
  };
}
