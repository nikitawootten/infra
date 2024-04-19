SHELL:=/usr/bin/env bash

NIX_CMD:=nix --experimental-features 'nix-command flakes'

# This help command was adapted from https://github.com/tiiuae/sbomnix
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN { \
	  FS = ":.*?## "; \
	  printf "\033[1m%-30s\033[0m %s\n", "TARGET", "DESCRIPTION" \
	} \
	{ printf "\033[32m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: develop
develop: ## Enter a nix-shell for development
	$(NIX_CMD) develop

.PHONY: test
test: ## Test flake outputs with "nix flake check"
	$(NIX_CMD) flake check

.PHONY: update
update: ## Update "flake.lock"
	$(NIX_CMD) flake update

.PHONY: switch-home
switch-home: ## Switch local home-manager config
	$(NIX_CMD) develop --command home-manager switch --flake .

.PHONY: build-home
build-home: ## Build local home-manager config
	$(NIX_CMD) develop --command home-manager build --flake .

.PHONY: switch-nixos
switch-nixos: ## Switch local NixOS config
	sudo $(NIX_CMD) develop --command nixos-rebuild switch --flake .#

.PHONY: build-nixos
build-nixos: ## Build local NixOS config
	sudo $(NIX_CMD) develop --command nixos-rebuild dry-activate --flake .#

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

	$(NIX_CMD) develop --command nixos-rebuild --flake ".#$(HOST)" \
		--target-host "$(HOST)" --use-remote-sudo switch \
		$(if $(BUILDER),--build-host "$(BUILDER)")

.PHONY: artifacts
artifacts: topology flake-graph ## Build all artifacts

out:
	mkdir out

.PHONY: topology
topology: out/topology.svg ## Build the nix-topology diagram

out/topology.svg: out flake.nix
	$(NIX_CMD) build .#topology.$(shell make --silent get-system).config.output
	cp result/main.svg out/topology.svg

.PHONY: flake-graph
flake-graph: out/flake-graph.svg ## Build the flake-graph diagram

out/flake-graph.svg: out flake.lock
	$(NIX_CMD) develop --command flake-graph flake.lock | dot -Tsvg > out/flake-graph.svg

.PHONY: clean
clean: ## Clean all artifacts
	rm -rf out

# Utility roles

.PHONY: get-hosts
list-hosts: ## List NixOS configuration names
	@$(NIX_CMD) develop --command nix flake show --json 2>/dev/null | jq -r ".nixosConfigurations | keys | .[] | @text"

.PHONY: get-system
get-system: ## Get the current system name
	@$(NIX_CMD) eval --impure --raw --expr 'builtins.currentSystem'
