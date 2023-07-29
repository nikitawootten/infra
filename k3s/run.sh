#!/usr/bin/env bash

K8S_AUTH_KUBECONFIG=./.temp_kubeconfig

if [[ ! -f "$K8S_AUTH_KUBECONFIG" ]]; then
    echo "Grabbing KubeConfig from Terraform bootstrap..."
    (cd ../bootstrap; terraform output -raw kubeconfig) > $K8S_AUTH_KUBECONFIG
fi

ANSIBLE_SECRETS_FILE=ansible_secrets.yaml
ANSIBLE_SECRETS_PATH=../../$ANSIBLE_SECRETS_FILE

if [[ ! -f "$ANSIBLE_SECRETS_PATH" ]]; then
    echo "Decrypting secrets..."
    (cd ../..; git secret reveal $ANSIBLE_SECRETS_FILE)
fi

K8S_AUTH_KUBECONFIG=$K8S_AUTH_KUBECONFIG ansible-playbook -i hosts site.yaml
