{ inputs, ... }:
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
}
