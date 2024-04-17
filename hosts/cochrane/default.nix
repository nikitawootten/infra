{ self, ... }: {
  imports = [ ./hardware-configuration.nix self.nixosModules.personal ];

  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  #personal.virtualbox.enable = true;
  personal.wireshark.enable = true;
  personal.flatpak.enable = true;
  personal.zsa.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];

  boot.kernelParams =
    [ "fbcon=rotate:1" "video=eDP-1:panel_orientation=right_side_up" ];

  fonts.fontconfig.subpixel.rgba = "vbgr";
}
