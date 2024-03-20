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
    # Provides secureboot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Manage flatpaks
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
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
    deploy-rs,
    flake-schemas,
    ...
  } @ inputs: let
    secrets = import ./secrets;
    keys = import ./keys.nix;

    # Args passed to home-manager and nixos modules
    specialArgs = {
      inherit self inputs secrets keys;
    };

    homes = self.lib.mkHomes {
      inherit specialArgs;
      configBasePath = ./homes;
      defaultModules = [self.homeModules.personal inputs.nix-index-database.hmModules.nix-index];
      homes = {
        nikita.system = "x86_64-linux";
        "nikita@voyager".system = "x86_64-linux";
        "nikita@dionysus".system = "x86_64-linux";
        "nikita@hades".system = "x86_64-linux";
        "nikita@olympus".system = "x86_64-linux";
        "nikita@cochrane".system = "x86_64-linux";
        "pi@raspberrypi4".system = "aarch64-linux";
        "nikita@iris".system = "aarch64-linux";
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
          # My home server
          username = "nikita";
          system = "x86_64-linux";
        };
        olympus = {
          # Old server, unused currently
          username = "nikita";
          system = "x86_64-linux";
        };
        voyager = {
          # My laptop and main development machine
          username = "nikita";
          system = "x86_64-linux";
        };
        dionysus = {
          # My desktop
          username = "nikita";
          system = "x86_64-linux";
        };
        cochrane = {
          # My GPD Pocket 2 mini-laptop
          username = "nikita";
          system = "x86_64-linux";
        };
        raspberrypi4 = {
          # Generic Raspberry Pi 4 (bootstrap config)
          username = "pi";
          system = "aarch64-linux";
        };
        iris = {
          # My Raspberry Pi 4
          username = "nikita";
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

    # Too intensive for GHA, disabling for now
    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

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
