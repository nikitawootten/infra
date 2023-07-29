SHELL:=/usr/bin/env bash

define IN_NIXSHELL
	nix-shell shell.nix --command '$1'
endef

.PHONY: build genlock clean

build: genlock
	$(call IN_NIXSHELL,nix-build)

genlock: yarn.lock yarn.nix

yarn.lock: package.json
	$(call IN_NIXSHELL,yarn install --mode update-lockfile)
	rm -fr node_modules

yarn.nix: yarn.lock
	$(call IN_NIXSHELL,yarn2nix > yarn.nix)

clean:
	rm -fr result yarn.*
