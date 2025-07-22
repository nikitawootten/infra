NIX_CMD:=nix --experimental-features 'nix-command flakes' develop .. --command
AGENIX_CMD:=$(NIX_CMD) agenix

.PHONY: edit
edit:
	$(AGENIX_CMD) -e $(KEY)

.PHONY: rekey
rekey:
	$(AGENIX_CMD) --rekey

.PHONY: list
list-keys:
	@find * -type f -name '*.age'

.PHONY: new-oauth2-key
new-oauth2-key:
	$(NIX_CMD) openssl rand -base64 64 | tr -cd 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkpqrstuvwxyz0123456789' | head -c 48
