{
  description = "My Nix-ified infrastructure and personal monorepo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    flake-utils.url = "github:numtide/flake-utils";
    # Provides secureboot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks";
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
    # Declerative management of flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    # Create VM/images/containers off of NixOS modules
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    flake-graph = {
      url = "github:nikitawootten/flake-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, flake-utils, pre-commit-hooks
    , ... }@inputs:
    let
      secrets = import ./secrets;
      keys = import ./keys.nix;

      # Args passed to home-manager and nixos modules
      specialArgs = { inherit self inputs secrets keys; };
    in {
      homeModules = import ./homeModules;

      nixosModules = import ./hostModules;
      nixosConfigurations = import ./hosts { inherit specialArgs nixpkgs; };

      darwinConfigurations =
        import ./darwinHosts { inherit darwin specialArgs; };
      darwinModules = import ./darwinModules;
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

      checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt.enable = true;
          nixfmt.package = pkgs.nixfmt-classic;
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        NIX_CONFIG =
          "extra-experimental-features = nix-command flakes repl-flake";
        name = "infra";
        packages = with pkgs;
          [
            nix
            git
            # So that Home-Manager knows what configuration to target
            hostname
            # Editor support
            nil
            pwgen
            jq
            graphviz
            helix
            tree
          ] ++ [
            inputs.home-manager.packages.${system}.default
            inputs.agenix.packages.${system}.default
            inputs.flake-graph.packages.${system}.default
          ] ++ self.checks.${system}.pre-commit-check.enabledPackages
          ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs;
            [
              # Secureboot
              sbctl
            ]);
      };

      formatter = pkgs.nixfmt-classic;
    });
}
