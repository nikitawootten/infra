{ inputs, modulesPath, pkgs, lib, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  environment.systemPackages = with pkgs; [ libraspberrypi raspberrypi-eeprom ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = lib.mkDefault true;

  # HACK for missing kernel module "sun4i-drm" causing build failure
  # More info here: https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  # Sane default for a new raspberry pi
  networking.useDHCP = lib.mkDefault true;

  # nixpkgs.crossSystem.system = "armv7l-linux";
}
