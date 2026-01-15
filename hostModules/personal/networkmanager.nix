{ lib, config, ... }:
let
  cfg = config.personal.networkmanager;
in
{
  options.personal.networkmanager = {
    enable = lib.mkEnableOption "networkmanager configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    users.users.${config.personal.user.name}.extraGroups = [ "networkmanager" ];

    # via https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1473408913
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  };
}
