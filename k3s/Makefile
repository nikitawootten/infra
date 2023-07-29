SHELL := /bin/bash

secrets_file := ansible_secrets.yaml
secrets_path := ../../$(secrets_file)

temp_kubeconfig_file := .temp_kubeconfig

.PHONY: deploy dependencies dash_token

deploy: $(secrets_path) $(temp_kubeconfig_file) dependencies
	K8S_AUTH_KUBECONFIG=$(temp_kubeconfig_file) ansible-playbook -i hosts site.yaml

$(secrets_path):
	@echo Decrypting secrets file...
	cd ../..; git secret reveal $(secrets_file)

# TODO grab IP from nix config? Or create an ssh entry in home-manager
danzek_addr=192.168.101.1

# Get kubernetes config from danzek
$(temp_kubeconfig_file):
	@echo Getting kubeconfig from danzek...
	ssh -t $(danzek_addr) "sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml; sudo chown nikita /tmp/k3s.yaml"
	scp $(danzek_addr):/tmp/k3s.yaml $(temp_kubeconfig_file)
	sed 's/127.0.0.1/$(danzek_addr)/g' $(temp_kubeconfig_file)

dependencies:
	@echo Downloading dependencies...
	ansible-galaxy install -r requirements.yaml

dash_token: $(temp_kubeconfig_file)
	kubectl -n kubernetes-dashboard create token admin-user
