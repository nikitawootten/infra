# `infra`

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Welcome to my Nix-ified infrastructure and personal monorepo.

![man made horrors beyond comprehension](https://gist.githubusercontent.com/nikitawootten/a0b5b3e0afdaaa8e02ace16b955da7ec/raw/flake-graph.svg)
_Flake dependency diagram [generated](./.github/workflows/artifacts.yaml) with [`nikitawootten/flake-graph`](https://github.com/nikitawootten/flake-graph)._

## Contents

This repository contains my Nix-related experiments.
Beyond managing dotfiles, I have also experimented with [packaging some of my commonly used applications](#packages) and [managing a homelab worth of services](#homelab).

Common operations are defined in the root [`Makefile`](./Makefile).
To list Makefile targets run `make help`.

### Hosts

| Hostname | Description |
| --- | --- |
| [`cochrane`](./modules/hosts/cochrane/) | GPD Pocket 2 |
| [`dionysus`](./modules/hosts/dionysus/) | Ryzen 2920X, NVIDIA 2080ti Workhorse |
| [`hades`](./modules/hosts/hades/) | Dell PowerEdge R720XD |
| [`iris`](./modules/hosts/iris.nix) | Raspberry Pi 4 |
| [`voyager`](./modules/hosts/voyager/) | Framework 13 i7-1185G7 |
| [`defiant`](./modules/hosts/defiant.nix) | MacBook Pro M4 |
| [`persephone`](./modules/hosts/persephone.nix) | Mac Mini M2 |

### Homelab

![network diagram](https://gist.githubusercontent.com/nikitawootten/a0b5b3e0afdaaa8e02ace16b955da7ec/raw/topology.svg)
_Network diagram [generated](./.github/workflows/artifacts.yaml) with [`oddlama/nix-topology`](https://github.com/oddlama/nix-topology)._

The [`homelab` module](./modules/homelab/) packages most of my homelab-specific configuration, including media management and monitoring.

For usage examples, refer to the [`hades`](./hosts/hades/) host configuration:

### Packages

This flake contains several packages that I rely on day to day:

- [`oscal-cli`](./packages/oscal-cli/)
- [`oscal-deep-diff`](./packages/oscal-deep-diff/)
- [`xspec`](./packages/xspec/)
- [`yepanywhere`](./packages/yepanywhere/)

These packages are **UNOFFICIAL**, experimental, potentially transient, and come with no guarantees or warranty.
If you would like to see these packages submitted [upstream](https://github.com/NixOS/nixpkgs) or to the [NUR](https://nur.nix-community.org/), **please open an issue on this repository as a signal of interest**.
