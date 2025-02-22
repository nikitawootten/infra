{ lib, config, ... }:
let cfg = config.personal.brew;
in {
  options.personal.brew = { enable = lib.mkEnableOption "homebrew config"; };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false;
        cleanup = "zap";
      };

      casks = [
        "arc"
        "discord"
        "proton-pass"
        "stats"
        "obsidian"
        "ghostty"
        "signal"
        "spotify"
        "protonvpn"
        "proton-drive"
      ];
    };

    programs.zsh.shellInit = ''
      export PATH=$PATH:${config.homebrew.brewPrefix}
    '';
  };
}
