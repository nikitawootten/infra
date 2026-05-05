{ inputs, lib, ... }:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (
    { ... }:
    {
      options._packages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Filtered into `packages` if `meta.unsupported` is `false`.";
      };
    }
  );

  config.perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      _packages = import ./../../packages { inherit pkgs; };
      # Filter out unsupported packages. Inspired by:
      # https://discourse.nixos.org/t/flake-parts-persystem-packages-systems-question/68512/2
      packages = lib.filterAttrs (
        _: p:
        let
          ok = builtins.tryEval (lib.isDerivation p && !(p.meta.unsupported or false));
        in
        ok.success && ok.value
      ) config._packages;
    };
}
