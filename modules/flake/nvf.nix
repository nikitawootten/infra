# This flake-parts module provides options for NVF modules.
{ lib, moduleLocation, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
in
{
  options.flake = {
    # Modeled after https://github.com/hercules-ci/flake-parts/blob/main/modules/nixosModules.nix
    nvfModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = mapAttrs (
        k: v: {
          _class = "nvf";
          _file = "${toString moduleLocation}#nvfModules.${k}";
          imports = [ v ];
        }
      );
      description = ''
        NVF modules.

        You may use this for reusable pieces of editor configuration.
      '';
    };
  };
}
