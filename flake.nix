{
  description = "My Nix-ified infrastructure and personal monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Dotfiles management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Provides hardware-specific NixOS modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Reproducible build environment
    devenv.url = "github:cachix/devenv/latest";
    # Provides a handy "command not found" nixpkgs hook
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Container management built on top of Docker-Compose
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, devenv, nix-index-database, agenix, arion, ... }:
    let
      personalPackages = import ./packages { inherit nixpkgs; lib = self.lib; };
      secrets = import ./secrets;

      # Args passed to home-manager and nixos modules
      specialArgs = {
        inherit devenv nixos-hardware nix-index-database agenix arion secrets;
      };

      homes = self.lib.mkHomes {
        inherit specialArgs;
        overlays = [ self.overlays.default ];
        configBasePath = ./homes;
        defaultModules = [ self.homeModules.default nix-index-database.hmModules.nix-index ];
        homes = {
          nikita.system = "x86_64-linux";
          "nikita@voyager".system = "x86_64-linux";
          "nikita@defiant".system = "x86_64-linux";
          "nikita@hades".system = "x86_64-linux";
          "nikita@olympus".system = "x86_64-linux";
        };
      };

      forEachSystem = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] f;
    in
    {
      # Contains top-level helpers for defining home-manager, nixos, and packaging configurations
      lib = import ./lib { inherit nixpkgs home-manager; };

      homeModules = import ./homeModules;
      homeConfigurations = homes.homeConfigurations;

      nixosModules = import ./hostModules;
      nixosConfigurations = self.lib.mkHosts {
        inherit specialArgs;
        overlays = [ self.overlays.default ];
        homeConfigs = homes.nixosHomeModules;
        configBasePath = ./hosts;
        defaultModules = [ self.nixosModules.default ];
        hosts = {
          hades = {
            username = "nikita";
            system = "x86_64-linux";
          };
          olympus = {
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

      devShells = forEachSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      in {
        default = import ./shell.nix { inherit pkgs; };
      });
    };
}
