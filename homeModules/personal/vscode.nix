{ pkgs, lib, config, ... }:
let cfg = config.personal.vscode;
in {
  options.personal.vscode = { enable = lib.mkEnableOption "vscode config"; };

  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;

    home.packages = with pkgs; [ code-cursor ];

    stylix.targets.vscode.enable = false;
  };
}
