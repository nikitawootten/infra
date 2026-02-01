{
  description = "My Nix-ified infrastructure and personal monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Dotfiles management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Provides hardware-specific NixOS modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Provides secure boot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit.follows = "pre-commit-hooks";
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
      inputs.darwin.follows = "darwin";
    };
    # Declarative management of flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    # Create VM/images/containers off of NixOS modules
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    flake-graph = {
      url = "github:nikitawootten/flake-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nvf-nixpkgs.url = "github:NixOS/nixpkgs/cad22e7d996aea55ecab064e84834289143e44a0";
    nvf = {
      url = "github:notashelf/nvf/v0.8";
      inputs.nixpkgs.follows = "nvf-nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      darwin,
      pre-commit-hooks,
      nvf,
      ...
    }:
    let
      secrets = import ./secrets;
      keys = import ./keys.nix;

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
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.home-manager.flakeModules.home-manager
        inputs.pre-commit-hooks.flakeModule
        inputs.nix-topology.flakeModule
      ];

      flake = {
        homeModules = import ./homeModules;

        nixosModules = import ./hostModules;
        nixosConfigurations = import ./hosts { inherit specialArgs nixpkgs; };

        darwinConfigurations = import ./darwinHosts { inherit darwin specialArgs; };
        darwinModules = import ./darwinModules;
      };

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          packages = (import ./packages { inherit pkgs; }) // {
            editor =
              let
                nvfConfig = nvf.lib.neovimConfiguration {
                  # Workaround see https://github.com/NotAShelf/nvf/issues/1312#issuecomment-3708175539
                  pkgs = inputs.nvf.inputs.nixpkgs.legacyPackages.x86_64-linux;
                  modules = [ ./editor ];
                };
              in
              nvfConfig.neovim;

          };

          pre-commit.settings.hooks = {
            nixfmt.enable = true;
          };

          topology.modules = [
            ./topology.nix
            {
              nixosConfigurations = {
                iris = self.nixosConfigurations.iris;
                hades = self.nixosConfigurations.hades;
                dionysus = self.nixosConfigurations.dionysus;
                hermes = self.nixosConfigurations.hermes;
              };
            }
          ];

          devShells.default = pkgs.mkShell {
            inherit (config.pre-commit.devShell) shellHook;
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";
            name = "infra";
            packages =
              with pkgs;
              [
                nix
                nixos-rebuild
                git
                # So that Home-Manager knows what configuration to target
                hostname
                # Editor support
                nixd
                pwgen
                jq
                graphviz
                tree
                openssl
              ]
              ++ [
                inputs.home-manager.packages.${system}.default
                inputs.agenix.packages.${system}.default
                inputs.flake-graph.packages.${system}.default
              ]
              ++ lib.lists.optionals pkgs.stdenv.isLinux (
                with pkgs;
                [
                  # Secure boot
                  sbctl
                ]
              );
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
