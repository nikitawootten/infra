{ pkgs, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    enableAutosuggestions = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
