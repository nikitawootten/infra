SHELL := /bin/bash

# For now, no secrets are needed
secrets_file := pve_bootstrap_secrets.yaml
secrets_path := ../../$(secrets_file)

.PHONY: deploy
deploy: dependencies #$(secrets_path)
	ansible-playbook -i hosts site.yaml

# $(secrets_path):
# 	@echo Decrypting secrets file...
# 	cd ../..; git secret reveal $(secrets_file)

.PHONY: dependencies
dependencies:
	@echo Downloading dependencies...
	ansible-galaxy install -r requirements.yaml
