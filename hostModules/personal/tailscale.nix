{ lib, config, ... }:
let cfg = config.personal.tailscale;
in {
  options.personal.tailscale = {
    enable = lib.mkEnableOption "tailscale configuration";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      # If SSH server is enabled, enable tailscale ssh
      extraUpFlags =
        lib.lists.optional config.personal.ssh-server.enable "--ssh";
    };
    networking.firewall.checkReversePath = "loose";
  };
}
