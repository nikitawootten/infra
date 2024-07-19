{ pkgs, lib, config, ... }:
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

      brews = [ ];

      casks =
        [ "arc" "discord" "figma" "google-chrome" "notion" "slack" "zoom" ];
    };

    programs.zsh.shellInit = ''
      export PATH=$PATH:${config.homebrew.brewPrefix}
    '';
  };
}
