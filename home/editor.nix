{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "monokai_pro";
      editor.cursorline = true;
      editor.indent-guides.render = true;
      keys.normal = {
        "C-s" = ":w";
      };
    };
  };

  programs.git.extraConfig.core.editor = "hx";
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.packages = with pkgs; [
    nodePackages.vscode-langservers-extracted
  ];
}
