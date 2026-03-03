{ ... }:
{
  flake.modules.homeManager.direnv =
    { pkgs, ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
      };
      programs.git.ignores = [ ".direnv" ];

      home.packages = with pkgs; [ devenv ];
    };
}
