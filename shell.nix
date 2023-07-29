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
  packages = with pkgs; [
    nix
    git
    # For provisioning K8s resources
    ansible
    kubectl
    kubevirt
    jq
    home-manager
    hostname
  ];
}
