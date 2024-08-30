{ pkgs, lib, config, ... }:
let cfg = config.personal.kitty;
in {
  options.personal.kitty = { enable = lib.mkEnableOption "kitty"; };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        package = lib.mkDefault pkgs.jetbrains-mono;
        name = lib.mkDefault "JetBrains Mono";
      };
    };

    programs.fuzzel.settings.main.terminal = "kitty -e";
  };
}
