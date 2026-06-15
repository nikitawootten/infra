SHELL:=/usr/bin/env bash

NIX_CMD:=nix --experimental-features 'nix-command flakes' --no-warn-dirty

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

.PHONY: build-machines
build-machines: ## Build every NixOS machine closure (warms the local store/cache)
	@$(NIX_CMD) flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]' | \
	while read -r host; do \
	  echo "==> $$host" >&2; \
	  $(NIX_CMD) build --no-link --print-out-paths \
	    ".#nixosConfigurations.$$host.config.system.build.toplevel"; \
	done

.PHONY: closure-diff
closure-diff: ## Diff machine closures between $(OLD) and $(NEW) out-path lists
	@paste -d' ' $(OLD) $(NEW) | while read -r old new; do \
	  echo "### $$new"; nix store diff-closures "$$old" "$$new"; echo; \
	done

.PHONY: machine-warnings
machine-warnings: ## Emit declared NixOS warnings per machine as JSON
	@$(NIX_CMD) flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]' | \
	while read -r host; do \
	  w="$$($(NIX_CMD) eval --json ".#nixosConfigurations.$$host.config.warnings" 2>/dev/null || echo '[]')"; \
	  jq -nc --arg h "$$host" --argjson w "$$w" '{host:$$h, warnings:$$w}'; \
	done | jq -s '.'

.PHONY: switch-nixos
switch-nixos: ## Switch local NixOS config
	$(NIX_CMD) develop --command nh os switch .#

.PHONY: build-nixos
build-nixos: ## Build local NixOS config
	$(NIX_CMD) develop --command nh os build .#

.PHONY: switch-darwin
switch-darwin:
	$(NIX_CMD) develop --command nh darwin switch .#

.PHONY: switch
switch: ## Switch NixOS or Darwin config
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) switch-darwin; \
	elif [ -d /etc/nixos/ ]; then \
		$(MAKE) switch-nixos; \
	else \
		echo "Unsupported configuration"; \
		exit 1; \
	fi

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

	$(NIX_CMD) develop --command nh os switch \
		--target-host "$(TARGET)" \
		$(if $(BUILDER),--build-host "$(BUILDER)") \
		--ask \
		".#$(HOST)"

.PHONY: artifacts
artifacts: flake-graph ## Build all artifacts

out:
	mkdir out

.PHONY: flake-graph
flake-graph: out/flake-graph.svg ## Build the flake-graph diagram

out/flake-graph.svg: out flake.lock
	$(NIX_CMD) develop --command bash -euo pipefail -c 'flake-graph --size flake.lock | dot -Tsvg > out/flake-graph.svg'

.PHONY: clean
clean: ## Clean all artifacts
	rm -rf out

# Utility roles

.PHONY: get-hosts
list-hosts: ## List NixOS configuration names
	@$(NIX_CMD) develop --command bash -c 'nix flake show --json 2>/dev/null | jq -r ".nixosConfigurations | keys | .[] | @text"'

.PHONY: get-system
get-system: ## Get the current system name
	@$(NIX_CMD) eval --impure --raw --expr 'builtins.currentSystem'
