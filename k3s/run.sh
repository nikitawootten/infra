#!/usr/bin/env bash

K8S_AUTH_KUBECONFIG=./.temp_kubeconfig

if [[ ! -f "$K8S_AUTH_KUBECONFIG" ]]; then
    (cd ../bootstrap; terraform output -raw kubeconfig) > $K8S_AUTH_KUBECONFIG
fi

K8S_AUTH_KUBECONFIG=$K8S_AUTH_KUBECONFIG ansible-playbook -i hosts site.yaml
