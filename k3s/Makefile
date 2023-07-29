SHELL := /bin/bash

secrets_file := ansible_secrets.yaml
secrets_path := ../../$(secrets_file)

temp_kubeconfig_file := .temp_kubeconfig

.PHONY: deploy dependencies

deploy: $(secrets_path) dependencies
	K8S_AUTH_KUBECONFIG=$(temp_kubeconfig_file) ansible-playbook -i hosts site.yaml

$(secrets_path):
	@echo Decrypting secrets file...
	cd ../..; git secret reveal $(secrets_file)

# Get kubernetes config from danzek
# TODO grab IP from nix config? Or create danzek host in home-manager
$(temp_kubeconfig_file):
	@echo Getting kubeconfig from danzek...
	ssh -t 192.168.101.1 "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml; sudo chown nikita /tmp/k3s.yaml"
	scp 192.168.101.1:/tmp/k3s.yaml $(temp_kubeconfig_file)

dependencies:
	@echo Downloading dependencies...
	ansible-galaxy install -r requirements.yaml
