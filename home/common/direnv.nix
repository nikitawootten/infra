{ devenv, system, ... }:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
    };
  };
  home.packages = [
    devenv.packages.${system}.devenv
  ];
  programs.git.ignores = [
    ".direnv"
  ];
}
