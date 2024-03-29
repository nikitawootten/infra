{ nixpkgs, lib, default-systems ? [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] }:
lib.mkPackageSet {
  inherit nixpkgs default-systems;
  packages = {
    oscal-cli.path = ./oscal-cli;
    oscal-deep-diff.path = ./oscal-deep-diff;
    xspec.path = ./xspec;
  };
}
