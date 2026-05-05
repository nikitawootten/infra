{ pkgs }:
{
  oscal-cli = pkgs.callPackage ./oscal-cli { };
  xspec = pkgs.callPackage ./xspec { };
  yepanywhere = pkgs.callPackage ./yepanywhere { };
}
