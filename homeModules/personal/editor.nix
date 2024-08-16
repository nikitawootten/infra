{ lib, config, pkgs, ... }:
let cfg = config.personal.editor;
in {
  options.personal.editor = { enable = lib.mkEnableOption "editor config"; };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      # Newer version of Helix available in unstable
      settings = {
        theme = lib.mkDefault "monokai_pro";
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
      # provides LSPs for CSS, SCSS, HTML, and JSON
      nodePackages.vscode-langservers-extracted
      yaml-language-server
      nodePackages.bash-language-server
      # markdown LSP
      marksman
      # Nix LSP
      nil
    ];
  };
}
