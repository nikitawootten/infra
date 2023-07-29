SHELL:=/bin/bash

# Run command in nix-shell for maximum reproducibility (idiot [me] proofing)
# Command itself must be wrapped in quotes
IN_NIXSHELL:=nix-shell shell.nix --command

.PHONY: test switch-nixos remote-switch-nixos switch-home update

test:
	$(IN_NIXSHELL) 'nix flake check'

# Switch local NixOS config
switch-nixos:
	$(IN_NIXSHELL) 'sudo nixos-rebuild switch --flake .#'

# Switch local home-manager config
switch-home:
	$(IN_NIXSHELL) 'home-manager switch --flake .'

update:
	$(IN_NIXSHELL) 'nix flake update'

# Default to connecting to the hostname directly
ADDR=$(HOST)

# Switch a remote NixOS config
# e.x. make remote-switch-nixos HOST="" USER="" ADDR=""
# or make remote-switch-nixos HOST="" USER="" (if HOST and ADDR are the same)
remote-switch-nixos:
	if [[ -z "$(HOST)" || -z "$(USER)" || -z "$(ADDR)" ]]; then \
  		echo 'one or more variables are undefined'; \
  		exit 1; \
	fi

	@echo Rebuilding configuration for $(HOST) on target $(USER)@$(ADDR)

	$(IN_NIXSHELL) 'NIX_SSHOPTS=-t nixos-rebuild --flake ".#$(HOST)" --impure \
		--target-host "$(USER)@$(ADDR)" --use-remote-sudo switch'
