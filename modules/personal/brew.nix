{ ... }:
{
  flake.darwinModules.brew =
    { config, ... }:
    {
      homebrew = {
        enable = true;

        # See https://github.com/nix-darwin/nix-darwin/issues/1787
        onActivation.extraFlags = [
          "--force-cleanup"
        ];

        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
        };

        masApps = {
          Tailscale = 1475387142;
          Xcode = 497799835;
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
          "protonvpn"
          "proton-drive"
          "zed"
          "jordanbaird-ice"
          "blender"
          "krita"
          "godot"
          "tor-browser"
          "obs"
          "utm"
          "google-chrome"
          "soduto"
        ];
      };

      programs.zsh.shellInit = ''
        export PATH=$PATH:${config.homebrew.prefix}/bin
      '';
    };
}
