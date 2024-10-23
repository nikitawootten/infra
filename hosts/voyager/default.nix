{ self, inputs, lib, pkgs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.personal
  ];

  powerManagement.enable = true;

  # Suspend-then-hibernate everywhere
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  personal.wireshark.enable = true;
  personal.flatpak.enable = true;
  personal.zsa.enable = true;
  personal.virtualbox.enable = true;

  services.fprintd.enable = lib.mkForce false;

  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/1p/wallhaven-1pomov.jpg";
    sha256 = "sha256-BnxTBI7qoXU/eXPWBm/jXCK9oNgOAA/6whj/aD5N2kk=";
  };
  stylix.polarity = "dark";

  home-manager.users.${config.personal.user.name} = {
    personal.gnome.enableGSConnect = true;
    personal.fonts.enable = true;
    home.packages = with pkgs; [ tor-browser-bundle-bin ];

    personal.roles.work.enable = true;

    imports = [ self.homeModules.protonmail-bridge ];
    services.protonmail-bridge.enable = true;
    services.protonmail-bridge.enableGitSendEmail = true;
  };

  programs.nix-ld.enable = true;

  networking.hostName = "voyager";

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.lanzaboote.enable = true;
  boot.lanzaboote.pkiBundle = "/etc/secureboot";

  personal.adb.enable = true;

  environment.systemPackages = with pkgs; [ sbctl android-studio ];

  # Needed to build aarch64 packages such as raspberry pi images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.supportedFilesystems = [ "ntfs" ];

  # Setup keyfile
  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".device =
    "/dev/disk/by-uuid/4a0aabeb-46fd-48b4-b11e-96ba338f25e7";
  boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".keyFile =
    "/crypto_keyfile.bin";
}
