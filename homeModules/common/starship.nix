{ lib, config, ... }:
let
  cfg = config.personal.starship;
in
{
  options.personal.starship = {
    enable = lib.mkEnableOption "shell config";
  };

  config = lib.mkIf cfg.enable {
    # shells share a common prompt
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        character.success_symbol = "[➜](bold green)";
        character.error_symbol = "[✗](bold red)";
        aws.disabled = true;
        battery.disabled = true;
        # warn me when I'm not in zsh
        shell.disabled = false;
        shell.zsh_indicator = "";
        # no nerdfont
        nodejs.symbol = "[⬢](bold green) ";
      };
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
