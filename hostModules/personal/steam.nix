{ config, lib, ... }:
let cfg = config.personal.steam;
in {
  options.personal.steam = {
    enable = lib.mkEnableOption "steam configuration";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
        "steam-runtime"
      ];
    programs.steam = { enable = true; };
  };
}
