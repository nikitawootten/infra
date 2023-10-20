{ lib, config, ... }:
let
  cfg = config.personal.tailscale;
in
{
  options.personal.tailscale = {
    enable = lib.mkEnableOption "tailscale configuration";
    enableSSH = lib.mkEnableOption "enable tailscale ssh";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";
    services.tailscale.extraUpFlags = lib.lists.optional cfg.enableSSH "--ssh";
  };
}