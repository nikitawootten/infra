{ pkgs, lib, config, ... }:
let
  cfg = config.personal.vpn;
in
{
  options.personal.vpn = {
    enable = lib.mkEnableOption "Desktop VPN configuration";
  };

  config = lib.mkIf cfg.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
  };
}
