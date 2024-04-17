AGENIX_CMD:=nix --experimental-features 'nix-command flakes' develop --command agenix

.PHONY: edit
edit:
	$(AGENIX_CMD) -e $(KEY)

.PHONY: rekey
rekey:
	$(AGENIX_CMD) --rekey

.PHONY: list
list-keys:
	@find * -type f -name '*.age'
