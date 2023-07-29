{
  description = "My Nix-ified infrastructure and personal monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    devenv.url = "github:cachix/devenv/latest";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, devenv, nix-index-database, arion, ... }:
    let
      personalLib = import ./lib;
      personalPackages = import ./packages { inherit nixpkgs personalLib; };
      overlays = [ personalPackages.overlay ];

      commonInherits = {
        inherit nixpkgs home-manager overlays personalLib;
        specialArgs = {
          inherit devenv nixos-hardware nix-index-database arion;
        };
      };

      homes = import ./home commonInherits;
    in
    {
      lib = personalLib;
      homeConfigurations = homes.homeConfigurations;
      nixosConfigurations = import ./hosts (commonInherits // {
        homeConfigs = homes.nixosHomeModules;
      });

      overlays.default = personalPackages.overlay;
      packages = personalPackages.packages;

      devShells = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system: {
          default = import ./shell.nix { pkgs = import nixpkgs { inherit system overlays; }; };
        });
    };
}
