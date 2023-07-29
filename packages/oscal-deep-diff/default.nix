# Adapted from https://git.sr.ht/~bwolf/language-servers.nix/tree/master/item/vscode-langservers-extracted/default.nix
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
  buildInputs = with pkgs; [ rsync ];

  configurePhase = ''
    ln -sf ${deps}/node_modules ./node_modules
  '';

  installPhase = ''
    mkdir -p $out/bin
    rsync -a --no-links ${deps}/node_modules $out
    chmod a+rwx $out/node_modules
    # cp -a ${deps}/deps/oscal-deep-diff/node_modules/oscal-deep-diff \
    #   $out/node_modules
    
    make_start () {
      target="$1"
      require="$2"
      echo '#!/usr/bin/env node' >"$1"
      echo "require('$2');" >>"$1"
      chmod a+x "$1"
    }

    make_start "$out/bin/oscal-deep-diff" \
      "$out/node_modules/@oscal/oscal-deep-diff/lib/cli/cli.js"
  '';

  dontUnpack = true;
  dontBuild = true;
}
