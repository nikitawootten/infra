{ config, pkgs, ... }:

{
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";
  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
