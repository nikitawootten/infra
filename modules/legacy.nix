{ inputs, self, ... }:
let
  secrets = import ./../secrets;
  keys = import ./../keys.nix;

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
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.pre-commit-hooks.flakeModule
  ];

  flake = {
    homeModules = import ./../homeModules;

    nixosModules = import ./../hostModules;
    nixosConfigurations = import ./../hosts {
      inherit specialArgs;
      nixpkgs = inputs.nixpkgs;
    };

    darwinConfigurations = import ./../darwinHosts {
      inherit specialArgs;
      darwin = inputs.darwin;
    };
    darwinModules = import ./../darwinModules;
  };

  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      packages = (import ./../packages { inherit pkgs; }) // {
        editor =
          let
            nvfConfig = inputs.nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [ ./../editor ];
            };
          in
          nvfConfig.neovim;

      };

      pre-commit.settings.hooks = {
        nixfmt.enable = true;
      };

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
}
