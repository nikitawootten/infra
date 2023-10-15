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
      inputs.home-manager.follows = "home-manager";
    };
    # Container management built on top of Docker-Compose
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Create VM/images/containers off of NixOS modules
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manage remote deployments of nodes
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Provides checks for additional output formats
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    devenv,
    nix-index-database,
    agenix,
    arion,
    nixos-generators,
    deploy-rs,
    flake-schemas,
    ...
  }: let
    secrets = import ./secrets;

    # Args passed to home-manager and nixos modules
    specialArgs = {
      inherit devenv nixos-hardware nix-index-database agenix arion nixos-generators secrets self;
    };

    homes = self.lib.mkHomes {
      inherit specialArgs;
      configBasePath = ./homes;
      defaultModules = [self.homeModules.personal nix-index-database.hmModules.nix-index];
      homes = {
        nikita.system = "x86_64-linux";
        "nikita@voyager".system = "x86_64-linux";
        "nikita@dionysus".system = "x86_64-linux";
        "nikita@hades".system = "x86_64-linux";
        "nikita@olympus".system = "x86_64-linux";
        "pi@raspberrypi4".system = "aarch64-linux";
      };
    };

    forEachSystem = f: nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] f;
  in {
    schemas = flake-schemas.schemas;

    # Contains top-level helpers for defining home-manager, nixos, and packaging configurations
    lib = import ./lib {inherit nixpkgs home-manager;};

    homeModules = import ./homeModules;
    homeConfigurations = homes.homeConfigurations;

    nixosModules = import ./hostModules;
    nixosConfigurations = self.lib.mkHosts {
      inherit specialArgs;
      homeConfigs = homes.nixosHomeModules;
      configBasePath = ./hosts;
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
        dionysus = {
          username = "nikita";
          system = "x86_64-linux";
        };
        raspberrypi4 = {
          username = "pi";
          system = "aarch64-linux";
        };
      };
    };

    deploy.nodes = {
      hades = {
        hostname = "hades";
        user = "nikita";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hades;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    packages = import ./packages {
      inherit nixpkgs;
      lib = self.lib;
    };

    devShells = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = import ./shell.nix {inherit pkgs;};
    });
  };
}
