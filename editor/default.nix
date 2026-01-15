{ ... }: {
  imports = [ ./filetree.nix ./theme.nix ];

  config = {
    vim = {
      viAlias = true;
      vimAlias = true;

      treesitter.enable = true;
      treesitter.context.enable = true;

      lsp = {
        enable = true;
        formatOnSave = true;
        inlayHints.enable = true;
        trouble.enable = true;
      };
      languages = {
        enableFormat = true;
        enableTreesitter = true;

        nix.enable = true;
        nix.format.type = [ "nixfmt" ];
        python.enable = true;
        python.format.type = [ "black" "isort" ];
        rust.enable = true;
        go.enable = true;
        html.enable = true;
        css.enable = true;
        ts.enable = true;
        java.enable = true;
        kotlin.enable = true;
        bash.enable = true;
        lua.enable = true;
        yaml.enable = true;
      };

      utility.sleuth.enable = true;
      utility.diffview-nvim.enable = true;
      autopairs.nvim-autopairs.enable = true;

      autocomplete.nvim-cmp.enable = true;

      telescope.enable = true;

      git.enable = true;

      notify.nvim-notify.enable = true;

      binds.whichKey.enable = true;
      comments.comment-nvim.enable = true;

      keymaps = [
        {
          key = "<leader>f?";
          mode = "n";
          silent = true;
          action = "<Cmd>Telescope keymaps<CR>";
        }
        {
          key = "<leader><leader>";
          mode = "n";
          silent = true;
          action = "<Cmd>Telescope find_files<CR>";
        }
        {
          key = "<leader>tc";
          mode = "n";
          silent = true;
          action = "<Cmd>Copilot suggestion toggle_auto_trigger<CR>";
        }
      ];

      assistant.copilot.enable = true;
    };
  };
}
