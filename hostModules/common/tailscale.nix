{ lib, config, ... }:
let
  cfg = config.personal.tailscale;
in
{
  options.personal.tailscale = {
    enable = lib.mkEnableOption "tailscale configuration";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";
  };
}
