{ ... }:
{
  flake.darwinModules.brew =
    { config, ... }:
    {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
        };

        masApps = {
          Tailscale = 1475387142;
        };
        brews = [ "mas" ];
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
          "darktable"
          "orion"
          "jellyfin-media-player"
          "unity"
          "godot"
          "keka"
          "tor-browser"
          "obs"
          "utm"
          "google-chrome"
          "soduto"
          "qflipper"
        ];
      };

      programs.zsh.shellInit = ''
        export PATH=$PATH:${config.homebrew.prefix}/bin
      '';
    };
}
