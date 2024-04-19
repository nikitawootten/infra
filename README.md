# `infra`

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Welcome to my Nix-ified infrastructure and personal monorepo.

## Projects

This repository contains my Nix-related experiments.
Beyond managing dotfiles, I have also experimented with [packaging some of my commonly used applications](#packages), [managing a homelab worth of services](#homelab), and [packaging a few flake utilities](#flake-utilities).

```text
.
├── homeModules/ # Re-usable Home-Manager modules
├── homes/       # Home-Manager configurations
├── hostModules/ # Re-usable NixOS modules
├── hosts/       # NixOS configurations
├── lib/         # Re-usable flake utilities
├── packages/    # My packages
├── Makefile     # Common operations defined here
├── README.md    # You are here
└── shell.nix    # Shell environment for Makefile operations
```

### Packages

This flake contains several packages that I rely on day to day:

- [`oscal-cli`](./packages/oscal-cli/)
- [`oscal-deep-diff`](./packages/oscal-deep-diff/)
- [`xspec`](./packages/xspec/)

These packages are **UNOFFICIAL**, experimental, potentially transient, and come with no guarantees or warranty.
If you would like to see these packages submitted [upstream](https://github.com/NixOS/nixpkgs) or to the [NUR](https://nur.nix-community.org/), **please open an issue on this repository as a signal of interest**.

### Homelab

The [`homelab` NixOS module](./hostModules/homelab/) packages most of my homelab-specific configuration, including media management and monitoring.

For usage examples, refer to the [`hades`](./hosts/hades/) and [`iris`](./hosts/iris/) host configurations:

### Flake Utilities

I have created a few Flake helpers and placed them in [`lib/`](./lib):

- [`mkHomes`](./lib/mkHomes.nix): Home-Manager configuration helper that generates Home-Manager and NixOS module compatible outputs and imports `user@hostname`-specific Home-Manager modules by path.
- [`mkHosts`](./lib/mkHosts.nix): NixOS configuration helper that imports a corresponding Home-Manager configuration and imports `hostname`-specific NixOS modules by path.

Refer to the [`flake.nix`](./flake.nix) for usage.

## Usage

Common operations are defined in the root [`Makefile`](./Makefile).
To list Makefile targets run `make help`.
