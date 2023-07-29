# Disclaimer: Although I am the author and current maintainer of
# OSCAL-deep-diff, and while I work on this project as part of my job, this is
# not an official package endorsed by my organization.
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

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${deps}/node_modules $out

    cat <<EOF > $out/bin/oscal-deep-diff
    #!/usr/bin/env node
    require('$out/node_modules/@oscal/oscal-deep-diff/lib/cli/cli.js');
    EOF

    chmod a+x $out/bin/oscal-deep-diff
  '';

  dontUnpack = true;
}
