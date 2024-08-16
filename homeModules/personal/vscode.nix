{ lib, config, ... }:
let cfg = config.personal.vscode;
in {
  options.personal.vscode = { enable = lib.mkEnableOption "gnome config"; };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "vscode" ];
    programs.vscode.enable = true;

    stylix.targets.vscode.enable = false;
  };
}
