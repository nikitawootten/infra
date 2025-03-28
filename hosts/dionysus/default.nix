{ self, pkgs, inputs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    self.nixosModules.dslr-webcam
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nix-topology.nixosModules.default
  ];

  topology.self = {
    hardware.info = "AMD Threadripper 2920X + NVIDIA 2080TI desktop";
    interfaces = {
      enp8s0 = { };
      wlp5s0 = {
        physicalConnections =
          [ (config.lib.topology.mkConnection "ap1" "wlan0") ];
      };
    };
  };

  personal.roles.work.enable = true;
  personal.roles.play.enable = true;
  personal.roles.security.enable = true;
  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.virtualbox.enable = true;
  personal.flatpak.enable = true;

  personal.nvidia = {
    enable = true;
    headless = false;
    suspend = true;
    betaDriver = true;
  };

  personal.zsa.enable = true;

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
    personal.fonts.enable = true;

    programs.firefox.profiles.default.settings = {
      "gfx.webrender.all" = true; # Force enable GPU acceleration
      "media.ffmpeg.vaapi.enabled" = true;
      "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
    };
  };

  programs.nix-ld.enable = true;

  # Disable auto-suspend
  services.xserver.displayManager.gdm.autoSuspend = false;

  # Multi-monitor support: Secondary monitor is rotated
  boot.kernelParams = [ "video=HDMI-1:panel_orientation=left_side_up" ];

  # Needed to build aarch64 packages such as raspberry pi images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
