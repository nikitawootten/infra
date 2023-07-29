SHELL := /bin/bash

secrets_file := ansible_secrets.yaml
secrets_path := ../../$(secrets_file)

temp_kubeconfig_file := .temp_kubeconfig

.PHONY: deploy
deploy: $(secrets_path) dependencies
	K8S_AUTH_KUBECONFIG=$(temp_kubeconfig_file) ansible-playbook -i hosts site.yaml

$(secrets_path):
	@echo Decrypting secrets file...
	cd ../..; git secret reveal $(secrets_file)

# Get kubernetes config from previous step
$(temp_kubeconfig_file):
	@echo Getting kubeconfig from terraform output...
	(cd ../2-pve_resources; terraform output -raw kubeconfig) > $(temp_kubeconfig_file)

.PHONY: dependencies
dependencies:
	@echo Downloading dependencies...
	ansible-galaxy install -r requirements.yaml
