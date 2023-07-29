{ nixpkgs, personalLib, default-systems ? [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] }:
personalLib.mkPackageSet {
  inherit nixpkgs default-systems;
  packages = {
    oscal-deep-diff = {
      path = ./oscal-deep-diff;
    };
  };
}
