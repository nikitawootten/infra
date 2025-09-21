{ ... }: {
  config = {
    vim = {
      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        highlight-undo.enable = true;
        nvim-scrollbar.enable = true;
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

      # Statusline already shows mode
      luaConfigRC.misc = ''
        vim.opt.showmode = false
      '';

      theme = {
        enable = true;
        name = "dracula";
      };
    };
  };
}
