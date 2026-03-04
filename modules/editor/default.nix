{ self, inputs, ... }:
{
  imports = [
    ./config.nix
    ./filetree.nix
    ./theme.nix
  ];

  perSystem =
    {
      pkgs,
      ...
    }:
    let
      nvfConfig = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          self.modules.nvf.editor
          self.modules.nvf.editor-filetree
          self.modules.nvf.editor-theme
        ];
      };
    in
    {
      packages = {
        editor = nvfConfig.neovim;
      };
    };

  flake.modules.homeManager.editor =
    { pkgs, ... }:
    {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.editor
      ];

      programs.git.settings.core.editor = "vim";
      home.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
    };
}
