{ ... }:
{
  flake.modules.homeManager.ghostty =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [
            "ghostty.desktop"
          ];
        };
      };
    };
}
