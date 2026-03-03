{
  self,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    self.modules.nixos.personal
    self.modules.nixos.dslr-webcam
    self.modules.nixos.gnome
    self.modules.nixos.role-play
    self.modules.nixos.role-security
    self.modules.nixos.flatpak
    self.modules.nixos.virtualbox
    self.modules.nixos.nvidia
    self.modules.nixos.zsa
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nix-topology.nixosModules.default
  ];

  topology.self = {
    hardware.info = "AMD Threadripper 2920X + NVIDIA 2080TI desktop";
    interfaces = {
      enp8s0 = { };
      wlp5s0 = {
        physicalConnections = [ (config.lib.topology.mkConnection "ap1" "wlan0") ];
      };
    };
  };

  # ALVR with support for the quest 2
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;
  environment.systemPackages = [ pkgs.android-tools ];
  users.users.${config.personal.user.name}.extraGroups = [ "adbusers" ];

  personal.nvidia = {
    headless = false;
    suspend = true;
    betaDriver = true;
  };

  dslr-webcam = {
    enable = true;
    camera-udev-product = "7b4/130/100"; # My beloved Olympus OM-D EM5 Mark II
    ffmpeg-hwaccel = true;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  networking.hostName = "dionysus";

  home-manager.users.${config.personal.user.name} = {
    imports = [
      self.modules.homeManager.firefox
    ];

    programs.firefox.profiles.default.settings = {
      "gfx.webrender.all" = true; # Force enable GPU acceleration
      "media.ffmpeg.vaapi.enabled" = true;
      "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
    };

    home.packages = with pkgs; [ zed-editor ];
  };

  programs.nix-ld.enable = true;

  # Disable auto-suspend
  services.displayManager.gdm.autoSuspend = false;

  # Multi-monitor support: Secondary monitor is rotated
  boot.kernelParams = [ "video=HDMI-1:panel_orientation=left_side_up" ];

  # Needed to build aarch64 packages such as raspberry pi images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
