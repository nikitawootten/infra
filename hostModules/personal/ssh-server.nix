{ lib, config, ... }:
let
  cfg = config.personal.ssh-server;
in
{
  options.personal.ssh-server = {
    enable = lib.mkEnableOption "ssh server configuration";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault false;
      };
    };
    # Passwordless sudo when SSH'ing with keys
    security.pam.enableSSHAgentAuth = lib.mkDefault true;
  };
}