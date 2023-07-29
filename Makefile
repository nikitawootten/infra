SHELL:=/usr/bin/env bash

# Run command in nix-shell for maximum reproducibility (idiot [me] proofing)
define IN_NIXSHELL
	nix-shell shell.nix --command '$1'
endef

.PHONY: help test update switch-home switch-nixos remote-switch-nixos

# This help command was adapted from https://github.com/tiiuae/sbomnix
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN { \
	  FS = ":.*?## "; \
	  printf "\033[1m%-30s\033[0m %s\n", "TARGET", "DESCRIPTION" \
	} \
	{ printf "\033[32m%-30s\033[0m %s\n", $$1, $$2 }'

test: ## Test flake outputs with "nix flake check"
	$(call IN_NIXSHELL,nix flake check)

update: ## Update "flake.lock"
	$(call IN_NIXSHELL,nix flake update)

switch-home: ## Switch local home-manager config
	$(call IN_NIXSHELL,home-manager switch --flake .)

switch-nixos: ## Switch local NixOS config
	$(call IN_NIXSHELL,sudo nixos-rebuild switch --flake .#)

# Default to connecting to the hostname directly
ADDR=$(HOST)

remote-switch-nixos: ## Switch a remote NixOS config (e.x. make remote-switch-nixos HOST="" USER="" ADDR="") ADDR defaults to HOST
	@if [[ -z "$(HOST)" || -z "$(USER)" || -z "$(ADDR)" ]]; then \
  		echo 'one or more variables are undefined'; \
  		exit 1; \
	fi

	@echo Rebuilding configuration for $(HOST) on target $(USER)@$(ADDR)

	$(call IN_NIXSHELL,NIX_SSHOPTS=-t nixos-rebuild --flake ".#$(HOST)" \
		--target-host "$(USER)@$(ADDR)" --use-remote-sudo switch)
