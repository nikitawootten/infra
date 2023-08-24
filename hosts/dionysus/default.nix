{ ... }:
{
  imports = [
    ./hardware-configuration.nix
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
  personal.nvidia.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.nikita = {
    description = "Nikita Wootten";
  };
}
