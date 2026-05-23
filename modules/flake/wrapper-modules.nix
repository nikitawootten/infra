{ lib, moduleLocation, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
in
{
  options.flake.wrapperModules = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
    apply = mapAttrs (
      k: v: {
        _file = "${toString moduleLocation}#wrapperModules.${k}";
        imports = [ v ];
      }
    );
    description = ''
      nix-wrapper-modules wrapper modules.
    '';
  };
}
