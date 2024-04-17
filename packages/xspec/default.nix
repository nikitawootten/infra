{ pkgs ? let
  lock = (builtins.fromJSON
    (builtins.readFile ../../flake.lock)).nodes.nixpkgs.locked;
  nixpkgs = fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
    sha256 = lock.narHash;
  };
in import nixpkgs { }, jre ? pkgs.jre
, saxon_cp ? "${pkgs.saxon-he}/saxon9he.jar", ... }:
let
  pname = "xspec";
  version = "2.2.4";
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  buildInputs = with pkgs; [ makeWrapper ];

  src = pkgs.fetchFromGitHub {
    owner = "xspec";
    repo = "xspec";
    rev = "v${version}";
    sha256 = "sha256-8cy/B8J6O86vYFQbhOVrAriOeD2kaQCRYfIS/xTP1KQ=";
  };

  configurePhase = ''
    mkdir -p $out/{xspec,bin}
    shopt -s extglob dotglob
    mv !($out) $out/xspec
  '';

  postFixup = ''
    makeWrapper $out/xspec/bin/xspec.sh $out/bin/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath [ jre ]} \
      --set-default SAXON_CP ${saxon_cp}
  '';
}
