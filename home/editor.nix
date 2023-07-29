{ pkgs, pkgs-unstable, ... }:
{
  programs.helix = {
    enable = true;
    # Newer version of Helix available in unstable
    package = pkgs-unstable.helix;
    settings = {
      theme = "monokai_pro";
      editor = {
        cursorline = true;
        indent-guides.render = true;
        soft-wrap.enable = true;
        lsp.display-inlay-hints = true;
      };
      keys.normal = {
        "C-s" = ":w";
        "C-l" = ":toggle-option soft-wrap.enable";
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
