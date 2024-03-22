# Shell for bootstrapping flake-enabled nix and other tooling
# Can be invoked from `nix-shell shell.nix` or `nix develop`
# Shamelessly stolen from https://github.com/Misterio77/nix-config
{ pkgs ? # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { }
, ...
}:
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
  name = "infra";
  packages = with pkgs; [
    nix
    git
    home-manager
    # So that Home-Manager knows what configuration to target
    hostname

    # Editor support
    nixpkgs-fmt
    nil

    pwgen
    jq
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    # Secureboot
    sbctl
  ]);
}
