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

      masApps = { Tailscale = 1475387142; };
      brews = [ "mas" "scrcpy" ];
      casks = [
        "discord"
        "element"
        "proton-pass"
        "stats"
        "obsidian"
        "ghostty"
        "signal"
        "spotify"
        "protonvpn"
        "proton-drive"
        "zed"
        "jordanbaird-ice"
        "blender"
        "krita"
        "maccy"
        "darktable"
        "orion"
        "jellyfin-media-player"
        "unity"
        "godot"
        "keka"
        "raspberry-pi-imager"
        "tor-browser"
        "obs"
        "utm"
        "google-chrome"
        "soduto"
        "qflipper"
      ];
    };

    programs.zsh.shellInit = ''
      export PATH=$PATH:${config.homebrew.brewPrefix}
    '';
  };
}
