{ lib, config, ...}:
let
  cfg = config.homelab.auth;
in
{
  imports = [
    ./keycloak.nix
  ];

  options.homelab.auth = {
    enable = lib.mkEnableOption "Enable auth stack";
  };

  config = lib.mkIf cfg.enable {
    homelab.auth.keycloak.enable = true;
  };
}
