{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  environment.systemPackages = [ pkgs.k3s ];
}
