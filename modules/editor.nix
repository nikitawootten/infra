{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      nvfConfig = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [ ./../editor ];
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
