SHELL:=/usr/bin/env bash
IN_NIXSHELL:=nix-shell shell.nix --command

.PHONY: build genlock clean

build: genlock
	nix-build

genlock: yarn.lock yarn.nix

yarn.lock: package.json
	$(IN_NIXSHELL) 'yarn install --mode update-lockfile'
	rm -fr node_modules

yarn.nix: yarn.lock
	$(IN_NIXSHELL) 'yarn2nix > yarn.nix'

clean:
	rm -fr result yarn.*
