# Disclaimer: This is not an official package endorsed by NIST.
{ pkgs ? let
  lock = (builtins.fromJSON
    (builtins.readFile ../../flake.lock)).nodes.nixpkgs.locked;
  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
    sha256 = lock.narHash;
  };
in import nixpkgs { }, jre ? pkgs.jre, ... }:
let
  pname = "oscal-cli";
  version = "1.0.3";
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  buildInputs = with pkgs; [ makeWrapper ];

  src = pkgs.fetchzip {
    url =
      "https://repo1.maven.org/maven2/gov/nist/secauto/oscal/tools/oscal-cli/cli-core/${version}/cli-core-${version}-oscal-cli.zip";
    sha256 = "sha256-s3pyOmYxMaq+EF009F3bq7xXVPQTWTcwZq+4AtNh2cU=";
    stripRoot = false;
  };

  configurePhase = ''
    mkdir $out
    mv lib SWIDTAG LICENSE* README* $out
    mkdir $out/bin
    # exclude other executable outputs (like oscal-cli.bat)
    mv bin/oscal-cli $out/bin
  '';

  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --set JAVACMD ${jre}/bin/java
  '';

  dontBuild = true;
  dontInstall = true;
}
