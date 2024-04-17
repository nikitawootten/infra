# from https://github.com/NixOS/nixpkgs/issues/197325#issuecomment-1304940413
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.allowedUnfreePackagesRegexs;
in {
  options = {
    allowedUnfreePackagesRegexs = mkOption {
      default = [ ];
      type = types.listOf types.str;
      description = "List of unfree packages allowed to be installed";
      example = lib.literalExpression ''[ "steam" ]'';
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      let
        pkgName = lib.getName pkg;
        matchPackges = reg: !builtins.isNull (builtins.match reg pkgName);
      in builtins.any matchPackges cfg;
  };
}
