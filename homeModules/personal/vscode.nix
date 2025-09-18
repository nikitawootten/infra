{ lib, config, ... }:
let cfg = config.personal.vscode;
in {
  options.personal.vscode = { enable = lib.mkEnableOption "vscode config"; };

  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;

    stylix.targets.vscode.enable = false;
  };
}
