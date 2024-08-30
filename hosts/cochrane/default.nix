{ pkgs, self, inputs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  #personal.virtualbox.enable = true;
  personal.wireshark.enable = true;
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

  personal.niri.enable = true;

  programs.nix-ld.enable = true;

  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    url =
      "https://github.com/dracula/wallpaper/blob/master/first-collection/nixos.png?raw=true";
    sha256 = "sha256-hJBs+1MYSAqxb9+ENP0AsHdUrvjTzjobGv57dx5pPGE=";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

  home-manager.users.${config.personal.user.name} = {
    personal.vscode.enable = true;
    personal.fonts.enable = true;
    personal.sectools.enable = true;
    personal.firefox.enable = true;

    home.packages = with pkgs; [ tor-browser-bundle-bin ];

    programs.niri.settings.outputs.eDP-1 = {
      transform.rotation = 270;
      scale = 1.25;
    };
  };
}
