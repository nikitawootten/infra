{ ... }:
{
  flake.modules.darwin.rancher =
    { lib, ... }:
    {
      homebrew.enable = lib.mkDefault true;
      homebrew.casks = [ "rancher" ];
      home-manager.sharedModules = [ { home.sessionPath = [ "$HOME/.rd/bin" ]; } ];
    };
}
