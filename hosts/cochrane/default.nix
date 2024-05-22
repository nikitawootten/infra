{ self, config, pkgs, ... }: {
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

  networking.hostName = "cochrane";
  home-manager.users.${config.personal.user.name} = {
    personal.vscode.enable = true;
    personal.gnome.enable = true;
    personal.gnome.enableGSConnect = true;
    personal.fonts.enable = true;
    personal.sectools.enable = true;
    personal.firefox.enable = true;
    personal.firefox.gnome-theme.enable = true;
    personal.firefox.sideberry-autohide = {
      enable = true;
      profiles = [ "default" ];
    };
    home.packages = with pkgs; [ tor-browser-bundle-bin ];
  };
}
