{ nixpkgs, ... }:
let
  # all systems to build packages for
  allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  # for each system, produce a single attrset in the shape of `system -> f`
  forEachSystem = f:
    builtins.listToAttrs (
      builtins.map (system: { name = system; value = f system; }) allSystems
    );
  mkPackageSet = packages:
    let
      # packages transformed from { a = {}; b = {}; } to
      # [ { name="a"; value={};} { name="b"; value={};} ]
      packagesList = builtins.map
        (name: { inherit name; value = builtins.getAttr name packages; })
        (builtins.attrNames packages);
    in
    {
      overlay = final: prev: builtins.mapAttrs
        (name: { path, ... }: prev.callPackage path { })
        packages;

      packages = forEachSystem (
        system:
        let
          # if a package set does not contain a "system" attr, default to all
          matchingPackages = builtins.filter
            (packageItem:
              ({ systems ? allSystems, ... }: builtins.elem system systems)
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
      );
    };
in
mkPackageSet {
  oscal-deep-diff = {
    path = ./oscal-deep-diff;
  };
}
