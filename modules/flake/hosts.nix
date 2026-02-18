{ inputs, self, ... }:
let
  secrets = import ./../../secrets;
  keys = import ./../../keys.nix;

  # Args passed to home-manager and nixos modules
  specialArgs = {
    inherit
      self
      inputs
      secrets
      keys
      ;
  };
in
{
  flake = {
    nixosConfigurations = import ./../../hosts {
      inherit specialArgs;
      nixpkgs = inputs.nixpkgs;
    };

    darwinConfigurations = import ./../../darwinHosts {
      inherit specialArgs;
      darwin = inputs.darwin;
    };
  };
}
