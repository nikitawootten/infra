{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      system,
      ...
    }:
    {
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
            nixfmt
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
    };
}
