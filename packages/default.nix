{ pkgs }:
{
  oscal-cli = pkgs.callPackage ./oscal-cli {};
  oscal-deep-diff = pkgs.callPackage ./oscal-deep-diff {};
  xspec = pkgs.callPackage ./xspec {};
}
