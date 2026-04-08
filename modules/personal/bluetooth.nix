{ ... }:
{
  flake.nixosModules.bluetooth =
    { config, lib, ... }:
    {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      personal.niri.extraSettings = lib.mkIf config.services.blueman.enable {
        spawn-at-startup = [
          [ "blueman-applet" ]
        ];
      };
    };
}
