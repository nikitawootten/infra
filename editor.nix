{ pkgs, ... }: {
  config = {
    vim = {
      viAlias = true;
      vimAlias = true;

      treesitter.enable = true;
      treesitter.context.enable = true;

      lsp = {
        enable = true;
        formatOnSave = true;
      };
      languages = {
        enableFormat = true;
        enableTreesitter = true;

        nix.enable = true;
        nix.format.package = pkgs.nixfmt-classic;
        nix.format.type = "nixfmt";
        markdown.enable = true;
      };

      utility.sleuth.enable = true;
      autopairs.nvim-autopairs.enable = true;

      autocomplete = { nvim-cmp.enable = true; };

      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        highlight-undo.enable = true;
      };

      ui = {
        borders.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        fastaction.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "dracula";
        };
      };

      theme = {
        enable = true;
        name = "dracula";
      };

      telescope.enable = true;

      git.enable = true;

      notify = { nvim-notify.enable = true; };

      luaConfigRC.misc = ''
        vim.opt.showmode = false
      '';
    };
  };
}
