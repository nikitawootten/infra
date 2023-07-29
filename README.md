# `infra`

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Welcome to my Nix-ified infrastructure and personal monorepo.

## Usage

Common operations are defined in the root [`Makefile`](./Makefile).
To list Makefile targets run `make help`.

## Projects

### Top level structure

```text
.
├── home/       # Home-Manager configurations
├── homelab/    # Additional homelab content
├── hosts/      # NixOS configurations
├── lib/        # Re-usable flake utilities
├── packages/   # My nixpkgs overlay
├── flake.lock
├── flake.nix
├── LICENSE
├── Makefile    # Common operations defined here
├── README.md
└── shell.nix   # Shell environment for Makefile operations
```
