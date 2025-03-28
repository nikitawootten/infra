{ pkgs, self, inputs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  personal.roles.play.enable = true;
  personal.roles.security.enable = true;
  personal.roles.work.enable = true;

  personal.networkmanager.enable = true;
  #personal.virtualbox.enable = true;
  personal.flatpak.enable = true;
  personal.zsa.enable = true;

  # Bootloader
  environment.systemPackages = with pkgs; [ sbctl ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-f190f8c5-0961-45c4-a785-d7f3692e65f8".device =
    "/dev/disk/by-uuid/f190f8c5-0961-45c4-a785-d7f3692e65f8";

  boot.supportedFilesystems = [ "ntfs" ];

  boot.kernelParams =
    [ "fbcon=rotate:1" "video=eDP-1:panel_orientation=right_side_up" ];

  fonts.fontconfig.subpixel.rgba = "vbgr";

  networking.hostName = "cochrane";

  personal.gnome.enable = true;
  programs.nix-ld.enable = true;

  home-manager.users.${config.personal.user.name} = {
    home.packages = with pkgs; [ tor-browser-bundle-bin ];
  };
}
