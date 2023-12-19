{ self, pkgs, nixos-hardware, ... }:
{
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
  ];

  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  personal.virtualbox.enable = true;
  personal.vpn.enable = true;
  personal.wireshark.enable = true;
  personal.flatpak.enable = true;

  personal.nvidia = {
    enable = true;
    headless = false;
    suspend = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  personal.zsa.enable = true;

  personal.dslr-webcam = {
    enable = true;
    camera-udev-product = "7b4/130/100"; # My beloved Olympus OM-D EM5 Mark II
    ffmpeg-hwaccel = true;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.nikita = {
    description = "Nikita Wootten";
  };
}
