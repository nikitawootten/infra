# `vscode-langservers-extracted`

This overlay package has been lightly adapted from [`~bwolf/languageservers.nix`](https://git.sr.ht/~bwolf/language-servers.nix/tree/master/item/vscode-langservers-extracted).

## What's Changed?

* Use of `yarn2nix` to avoid IFD-related issues

    This is to avoid issues [like this](https://github.com/NixOS/nix/issues/4265).

* Can be built independently or in flake (defaultible `pkgs`)

## Updating

To update the NPM package:

1. Change the dependency version in [`package.json`](./package.json)
2. Run `make genlock`
