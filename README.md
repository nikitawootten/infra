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

### Packages

This flake contains an overlay with several packages that I rely on day to day:

- [`oscal-cli`](./packages/oscal-cli/)
- [`oscal-deep-diff`](./packages/oscal-deep-diff/)
- [`xspec`](./packages/xspec/)

These packages are **UNOFFICIAL**, experimental, potentially transient, and come with no guarantees or warranty.
If you would like to see these packages submitted [upstream](https://github.com/NixOS/nixpkgs) or to the [NUR](https://nur.nix-community.org/), **please open an issue on this repository as a signal of interest**.
