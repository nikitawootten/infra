{ inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake = {
    nixosModules = {
      homelab.imports = [ ./../hostModules/homelab ];
    };
  };
}
