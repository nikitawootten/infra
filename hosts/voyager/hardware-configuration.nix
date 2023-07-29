# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/22be342b-ec17-42d6-9f24-978de7028706";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-19fb8ebd-b8e8-4f4a-9fb7-54085f487997".device = "/dev/disk/by-uuid/19fb8ebd-b8e8-4f4a-9fb7-54085f487997";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/CE92-0B09";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/49ac16b1-0b62-4524-9e66-9f9bb729c0df"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp170s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  #hardware.video.hidpi.enable = lib.mkDefault true;
}
