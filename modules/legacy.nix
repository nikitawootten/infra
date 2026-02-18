{ inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake = {
    homeModules = import ./../homeModules;
    nixosModules = import ./../hostModules;
    darwinModules = import ./../darwinModules;
  };
}
