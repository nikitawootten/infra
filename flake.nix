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

  outputs = { nixpkgs, home-manager, nixos-hardware, devenv, nix-index-database, agenix, arion, ... }:
    let
      personalLib = import ./lib;
      personalPackages = import ./packages { inherit nixpkgs personalLib; };
      secrets = import ./secrets;

      specialArgs = {
        inherit devenv nixos-hardware nix-index-database agenix arion secrets;
      };

      homes = import ./home {
        inherit nixpkgs home-manager specialArgs personalLib;
        overlays = [ personalPackages.overlay ];
      };

      forEachSystem = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] f;
    in rec
    {
      lib = import ./lib;

      homeConfigurations = homes.homeConfigurations;

      nixosModules = import ./hostModules;
      nixosConfigurations = lib.mkHosts {
        inherit nixpkgs specialArgs;
        overlays = [ overlays.default ];
        homeConfigs = homes.nixosHomeModules;
        configBasePath = ./hosts;
        defaultModules = [ nixosModules.default ];
        hosts = {
          hades = {
            username = "nikita";
            system = "x86_64-linux";
          };
          voyager = {
            username = "nikita";
            system = "x86_64-linux";
          };
        };
      };

      overlays.default = personalPackages.overlay;
      packages = personalPackages.packages;

      devShells = forEachSystem (system: {
        default = import ./shell.nix { pkgs = import nixpkgs { inherit system; overlays = [ overlays.default ] ; }; };
      });
    };
}
