{ ... }:
{
  flake.nixosModules.bluetooth = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
