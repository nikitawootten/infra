# Disclaimer: Although I am the author of OSCAL-deep-diff, this is not an
# official package endorsed by NIST.
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
  pname = "oscal-deep-diff";
  version = (builtins.fromJSON (builtins.readFile ./package.json)).dependencies."@oscal/oscal-deep-diff";
  deps = pkgs.mkYarnModules {
    inherit pname version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    # Prevent IFD nonsense causing "but I am a 'x86_64-linux'" errors
    yarnNix = ./yarn.nix;
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  nativeBuildInputs = with pkgs; [ ];
  buildInputs = with pkgs; [ ];

  configurePhase = ''
    mkdir -p $out/bin
    ln -s ${deps}/node_modules $out
  '';

  installPhase = ''
    cat <<EOF > $out/bin/oscal-deep-diff
    #!${pkgs.nodejs}/bin/node
    require('$out/node_modules/@oscal/oscal-deep-diff/lib/cli/cli.js');
    EOF

    chmod a+x $out/bin/oscal-deep-diff
  '';

  dontUnpack = true;
}
