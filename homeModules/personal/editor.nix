{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  cfg = config.personal.editor;
in
{
  options.personal.editor = {
    enable = lib.mkEnableOption "editor config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.editor ];

    programs.git.settings.core.editor = "vim";
    home.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
