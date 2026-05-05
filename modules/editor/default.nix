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
          self.nvfModules.editor
          self.nvfModules.editor-filetree
          self.nvfModules.editor-theme
        ];
      };
    in
    {
      _packages = {
        editor = nvfConfig.neovim;
      };
    };

  flake.homeModules.editor =
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
