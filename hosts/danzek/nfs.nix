{ config, pkgs, ... }:

{
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /backplane/applications 192.168.101.0/24(rw,sync,no_subtree_check) 
  '';
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
