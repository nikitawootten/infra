{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
