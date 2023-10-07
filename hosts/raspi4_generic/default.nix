{ modulesPath, pkgs, nixos-hardware, username, ... }:
{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  personal.tailscale.enable = false;
  personal.upgrade-diff.enable = false;

  users.users.${username} = {
    # DEFINITELY change this :)
    initialPassword = "raspberry";
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  services.openssh.settings.PasswordAuthentication = true;

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}