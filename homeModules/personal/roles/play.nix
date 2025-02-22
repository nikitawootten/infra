{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.work;
in {
  options.personal.roles.play = {
    enable = lib.mkEnableOption "Play related software and configuration";
  };

  config =
    lib.mkIf cfg.enable { home.packages = with pkgs; [ prismlauncher ]; };
}
