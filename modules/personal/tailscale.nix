{ ... }:
{
  flake.nixosModules.tailscale = {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--ssh" ];
    };
    networking.firewall.checkReversePath = "loose";
  };
}
