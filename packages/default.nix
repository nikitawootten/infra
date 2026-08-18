{ pkgs }:
{
  lotion = pkgs.callPackage ./lotion { };
  oscal-cli = pkgs.callPackage ./oscal-cli { };
  xspec = pkgs.callPackage ./xspec { };
}
