
.PHONY: test
test:
	nix flake check

.PHONY: switch-nixos
switch-nixos:
	sudo nixos-rebuild switch --flake .#

.PHONY: switch-home
switch-home:
	home-manager switch --flake .

.PHONY: update
update:
	nix flake update
