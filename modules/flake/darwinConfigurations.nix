# Modeled after https://github.com/hercules-ci/flake-parts/blob/main/modules/nixosConfigurations.nix
{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    literalExpression
    ;
in
{
  options = {
    flake.darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated nix-darwin configurations.

        `darwinConfigurations` is for specific machines. If you want to expose
        reusable configurations, add them to darwinModules, so that you can reference
        them in this or another flake's `darwinConfigurations`.
      '';
      example = literalExpression ''
        {
          my-machine = inputs.darwin.lib.darwinSystem {
            modules = [
              ./my-machine/darwin-configuration.nix
              config.darwinModules.my-module
            ];
          };
        }
      '';
    };
  };
}
