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

`make directory` can help if you're lost:

<!--
TODO: When I'm feeling really bored, generate automatically with a pre-commit hook
-->

```console
$ make directory
.
├── darwinHosts
│   ├── defiant
│   │    { MacBook Pro M4
│   └── persephone
│        { Work Mac Mini M2
├── darwinModules
│   └── personal
├── homeModules
│   ├── personal
│   │    ⎧ Misc. config, dotfiles, applications, and hacky utilities
│   │    ⎨ Makes every computer it infects feel like home
│   │    ⎩ Note: Look around before using unless you want to become me
│   └── protonmail-bridge
├── hostModules
│   ├── dslr-webcam
│   │    { Module I use to configure my Olympus OM-D camera as a webcam
│   ├── homelab
│   │    { Re-usable homelab modules for media, observability, and more
│   ├── omada-controller
│   ├── personal
│   │    { Misc. server and desktop config
│   └── raspi4sd
│        { Raspberry Pi 4 SD card configuration
├── hosts
│   ├── cochrane
│   │    { GPD Pocket 2 mini-computer, neglected & seldom used
│   ├── dionysus
│   │    { Custom-build workhorse (Ryzen 2920X, NVIDIA 2080ti)
│   ├── hades
│   │    { Dell PowerEdge R720XD, primary home server
│   ├── hermes
│   ├── iris
│   │    { Raspberry Pi 4, secondary home server
│   └── voyager
│        { Framework 13 (11th Gen Intel), primary laptop
├── packages
│   ├── oscal-cli
│   ├── oscal-deep-diff
│   └── xspec
└── secrets
     { Age secrets managed by AgeNix
```

### Packages

This flake contains several packages that I rely on day to day:

- [`oscal-cli`](./packages/oscal-cli/)
- [`oscal-deep-diff`](./packages/oscal-deep-diff/)
- [`xspec`](./packages/xspec/)

These packages are **UNOFFICIAL**, experimental, potentially transient, and come with no guarantees or warranty.
If you would like to see these packages submitted [upstream](https://github.com/NixOS/nixpkgs) or to the [NUR](https://nur.nix-community.org/), **please open an issue on this repository as a signal of interest**.

### Homelab

![network diagram](https://gist.githubusercontent.com/nikitawootten/a0b5b3e0afdaaa8e02ace16b955da7ec/raw/topology.svg)
_Network diagram [generated](./.github/workflows/artifacts.yaml) with [`oddlama/nix-topology`](https://github.com/oddlama/nix-topology)._

The [`homelab` NixOS module](./hostModules/homelab/) packages most of my homelab-specific configuration, including media management and monitoring.

For usage examples, refer to the [`hades`](./hosts/hades/) and [`iris`](./hosts/iris/) host configurations:
