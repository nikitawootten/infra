AGENIX_CMD:=nix run github:ryantm/agenix --

.PHONY: edit
edit:
	$(AGENIX_CMD) -e $(KEY)

.PHONY: rekey
rekey:
	$(AGENIX_CMD) --rekey

.PHONY: list
list-keys:
	@find * -type f -name '*.age'
