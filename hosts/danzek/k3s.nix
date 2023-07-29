{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    6443 # needed to access k8s API
    10250 # needed by metrics-server
  ];
  services.k3s = {
    enable = true;
    role = "server";
    # Ingress configured by playbook
    extraFlags = "--disable traefik";
  };
}
