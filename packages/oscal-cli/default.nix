# Disclaimer: This is not an official package endorsed by NIST.
{ pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { }
, ...
}:
let
  pname = "oscal-cli";
  version = "0.3.3";
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  buildInputs = with pkgs; [ makeWrapper ];

  src = pkgs.fetchzip {
    url = "https://repo1.maven.org/maven2/gov/nist/secauto/oscal/tools/oscal-cli/cli-core/${version}/cli-core-${version}-oscal-cli.zip";
    sha256 = "sha256-8NlFVNhjD4VjxLU9U8HY2McLbleuNUPXG5kED1Vuldw=";
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
      --set JAVACMD ${pkgs.jre}/bin/java
  '';
}
