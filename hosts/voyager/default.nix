{ self, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
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

  services.fprintd = {
    enable = true;
  };

  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  # personal.virtualbox.enable = true;
  personal.wireshark.enable = true;
  personal.flatpak.enable = true;
  personal.zsa.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Needed to build aarch64 packages such as raspberry pi images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.supportedFilesystems = [ "ntfs" ];

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".device = "/dev/disk/by-uuid/4a0aabeb-46fd-48b4-b11e-96ba338f25e7";
  boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".keyFile = "/crypto_keyfile.bin";
}
