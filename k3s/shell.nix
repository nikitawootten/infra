{ pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked;
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
  name = "infra-k3s";
  packages = with pkgs; [
    nix
    git
    git-secret

    kubectl
    helm

    ansible
    ansible-lint

    jq

    # required for k8s ansible modules
    python310
    python310Packages.pyyaml
    python310Packages.kubernetes
  ];
}
