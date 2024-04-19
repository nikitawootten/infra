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
    vpnconfinement.url = "github:Maroka-chan/VPN-Confinement";
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      secrets = import ./secrets;
      keys = import ./keys.nix;

      # Args passed to home-manager and nixos modules
      specialArgs = { inherit self inputs secrets keys; };

      homes = import ./homes {
        inherit specialArgs;
        lib = self.lib;
      };
    in {
      # Contains top-level helpers for defining home-manager, nixos, and packaging configurations
      lib = import ./lib { inherit nixpkgs home-manager; };

      homeModules = import ./homeModules;
      homeConfigurations = homes.homeConfigurations;

      nixosModules = import ./hostModules;
      nixosConfigurations = import ./hosts {
        inherit specialArgs;
        lib = self.lib;
        homeConfigs = homes.nixosHomeModules;
      };
    } // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-topology.overlays.default ];
      };

      packages = import ./packages { inherit pkgs; };

      topology = import inputs.nix-topology {
        inherit pkgs;
        modules = [
          ./topology.nix
          # { nixosConfigurations = self.nixosConfigurations; }
          {
            nixosConfigurations = {
              iris = self.nixosConfigurations.iris;
              hades = self.nixosConfigurations.hades;
              dionysus = self.nixosConfigurations.dionysus;
            };
          }
        ];
      };

      devShells.default = pkgs.mkShell {
        NIX_CONFIG =
          "extra-experimental-features = nix-command flakes repl-flake";
        name = "infra";
        packages = with pkgs;
          [
            opentofu

            nix
            git
            # So that Home-Manager knows what configuration to target
            hostname
            # Editor support
            nixpkgs-fmt
            nil
            pwgen
            jq
          ] ++ [
            inputs.home-manager.packages.${system}.default
            inputs.agenix.packages.${system}.default
          ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs;
            [
              # Secureboot
              sbctl
            ]);
      };

      formatter = pkgs.nixfmt-classic;
    });
}
