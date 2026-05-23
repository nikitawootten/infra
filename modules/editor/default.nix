{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.wrapperModules.editor =
    { pkgs, ... }:
    {
      config.settings.config_directory = ./config;

      config.specs.lze = with pkgs.vimPlugins; [
        lze
        {
          data = lzextras;
          name = "lzextras";
        }
      ];

      config.specs.general = {
        after = [ "lze" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          {
            data = vim-sleuth;
            lazy = false;
          }
          snacks-nvim
          nvim-lspconfig
          trouble-nvim
          nvim-surround
          vim-startuptime
          blink-cmp
          colorful-menu-nvim
          lualine-nvim
          gitsigns-nvim
          which-key-nvim
          fidget-nvim
          nvim-lint
          conform-nvim
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
        ];
      };

      config.specs.lua = {
        after = [ "general" ];
        lazy = true;
        data = [ pkgs.vimPlugins.lazydev-nvim ];
      };

      config.specs.colorscheme = {
        lazy = true;
        data = pkgs.vimPlugins.tokyonight-nvim;
      };

      config.specs.copilot = {
        lazy = true;
        data = pkgs.vimPlugins.copilot-lua;
      };

      config.runtimePkgs = with pkgs; [
        # general
        git
        lazygit
        tree-sitter
        ripgrep
        fd
        copilot-language-server
        # nix
        nixd
        nixfmt
        # lua
        lua-language-server
        stylua
        # python
        basedpyright
        black
        isort
        # rust
        rust-analyzer
        rustfmt
      ];
    };

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = p: lib.getName p == "copilot-language-server";
      };
    in
    {
      _packages.editor = inputs.nix-wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [ self.wrapperModules.editor ];
      };
    };

  flake.homeModules.editor =
    { pkgs, ... }:
    {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.editor
      ];

      programs.git.settings.core.editor = "nvim";
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      home.shellAliases.vim = "nvim";
    };
}
