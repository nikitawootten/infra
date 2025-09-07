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
          lsp.display-messages = true;
        };
        keys.normal = {
          space.space = "file_picker";
          space.n = ":lsp-workspace-command today";
          "C-s" = ":w";
          "C-l" = ":toggle-option soft-wrap.enable";
        };
      };
      languages = {
        language = [
          {
            name = "xml";
            language-servers = [ "lemminx" ];
          }
          {
            name = "python";
            language-servers = [ "pyright" ];
          }
        ];
        language-server = {
          lemminx.command = lib.getExe pkgs.lemminx;
          pyright = {
            command = "${pkgs.pyright}/bin/pyright-langserver";
            args = [ "--stdio" ];
            config = { };
          };
        };
      };
    };

    home.packages = with pkgs; [
      # provides LSPs for CSS, SCSS, HTML, and JSON
      # nodePackages.vscode-langservers-extracted
      yaml-language-server
      nodePackages.bash-language-server
      # Nix LSP
      nixd
      nixfmt-classic
      shellcheck
      markdown-oxide
      sourcekit-lsp
      kotlin-language-server
    ];

    programs.git.extraConfig.core.editor = "hx";
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };
}
