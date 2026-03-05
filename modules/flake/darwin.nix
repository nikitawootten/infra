# This flake-parts module provides options for nix-darwin configurations and modules.
{ lib, moduleLocation, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    literalExpression
    ;
in
{
  options.flake = {
    # Modeled after https://github.com/hercules-ci/flake-parts/blob/main/modules/nixosConfigurations.nix
    darwinConfigurations = mkOption {
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

    # Modeled after https://github.com/hercules-ci/flake-parts/blob/main/modules/nixosModules.nix
    darwinModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = mapAttrs (
        k: v: {
          _class = "darwin";
          _file = "${toString moduleLocation}#darwinModules.${k}";
          imports = [ v ];
        }
      );
      description = ''
        Nix-Darwin modules.

        You may use this for reusable pieces of configuration, service modules, etc.
      '';
    };
  };
}
