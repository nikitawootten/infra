{ ... }:
let
  toggle_mapping = "<C-b>";
in
{
  config = {
    vim = {
      filetree.neo-tree.enable = true;
      filetree.neo-tree.setupOpts = {
        window.mappings.${toggle_mapping} = "close_window";
      };

      keymaps = [
        {
          key = toggle_mapping;
          mode = "n";
          silent = true;
          action = "<Cmd>Neotree focus<CR>";
        }
      ];
    };
  };
}
