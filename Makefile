SHELL:=/usr/bin/env bash

# Run command in nix-shell for maximum reproducibility (idiot [me] proofing)
define IN_NIXSHELL
	nix-shell shell.nix --command '$1'
endef

# This help command was adapted from https://github.com/tiiuae/sbomnix
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN { \
	  FS = ":.*?## "; \
	  printf "\033[1m%-30s\033[0m %s\n", "TARGET", "DESCRIPTION" \
	} \
	{ printf "\033[32m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: test
test: ## Test flake outputs with "nix flake check"
	$(call IN_NIXSHELL,nix flake check)

.PHONY: update
update: ## Update "flake.lock"
	$(call IN_NIXSHELL,nix flake update)

.PHONY: switch-home
switch-home: ## Switch local home-manager config
	$(call IN_NIXSHELL,home-manager switch --flake .)

.PHONY: build-home
build-home: ## Build local home-manager config
	$(call IN_NIXSHELL,home-manager build --flake .)

.PHONY: switch-nixos
switch-nixos: ## Switch local NixOS config
	$(call IN_NIXSHELL,sudo nixos-rebuild switch --flake .#)

.PHONY: build-nixos
build-nixos: ## Build local NixOS config
	$(call IN_NIXSHELL,sudo nixos-rebuild dry-activate --flake .#)

# Default to connecting to the host directly
TARGET=$(HOST)
# Default to using the local machine as the builder
BUILDER=

.PHONY: remote-switch-nixos
remote-switch-nixos: ## Switch a remote NixOS config (e.x. make remote-switch-nixos HOST="" TARGET="" BUILDER="") TARGET defaults to HOST, BUILDER can be undefined
	@if [[ -z "$(HOST)" || -z "$(TARGET)" ]]; then \
  		echo 'one or more variables are undefined'; \
  		exit 1; \
	fi

	@echo Rebuilding configuration for $(HOST) on target $(TARGET) \
		$(if $(BUILDER),with builder $(BUILDER))

	$(call IN_NIXSHELL,nixos-rebuild --flake ".#$(HOST)" \
		--target-host "$(HOST)" --use-remote-sudo switch \
		$(if $(BUILDER),--build-host "$(BUILDER)"))

# Utility roles

.PHONY: get-hosts
list-hosts: ## List NixOS configuration names
	@$(call IN_NIXSHELL,nix flake show --json 2>/dev/null | jq -r ".nixosConfigurations | keys | .[] | @text")
