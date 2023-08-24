{ nixpkgs, packages, default-systems }:
let
  # for each system, produce a single attrset in the shape of `system -> f`
  forEachSystem = f:
    builtins.listToAttrs (
      builtins.map (system: { name = system; value = f system; }) default-systems
    );
  # packages transformed from { a = {}; b = {}; } to
  # [ { name="a"; value={};} { name="b"; value={};} ]
  packagesList = builtins.map
    (name: { inherit name; value = builtins.getAttr name packages; })
    (builtins.attrNames packages);
in
forEachSystem (
  system:
  let
    # if a package set does not contain a "system" attr, default to all
    matchingPackages = builtins.filter
      (packageItem:
        ({ systems ? default-systems, ... }: builtins.elem system systems)
          packageItem.value)
      packagesList;
    callPackage = nixpkgs.legacyPackages.${system}.callPackage;
  in
  builtins.listToAttrs
    (
      builtins.map
        ({ name, value, ... }:
          { inherit name; value = callPackage value.path { }; })
        matchingPackages
    )
)
