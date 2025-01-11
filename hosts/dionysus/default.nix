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

  personal.gnome.enable = true;

  personal.networkmanager.enable = true;
  personal.printing.enable = true;
  personal.steam.enable = true;
  personal.docker.enable = true;
  # personal.virtualbox.enable = true;
  personal.wireshark.enable = true;
  personal.flatpak.enable = true;

  personal.nvidia = {
    enable = true;
    headless = false;
    suspend = true;
    betaDriver = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  personal.zsa.enable = true;

  personal.adb.enable = true;

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

  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/1p/wallhaven-1pym61.jpg";
    sha256 = "sha256-jj/vKZTW1zwWK/dd8CewVbpCS7xdA/DC65yqPxFRxYU=";
  };
  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/atelier-estuary.yaml";
  stylix.polarity = "dark";

  home-manager.users.${config.personal.user.name} = {
    personal.fonts.enable = true;

    programs.firefox.profiles.default.settings = {
      "gfx.webrender.all" = true; # Force enable GPU acceleration
      "media.ffmpeg.vaapi.enabled" = true;
      "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
    };

    personal.roles.work.enable = true;
  };

  programs.nix-ld.enable = true;

  # Disable auto-suspend
  services.xserver.displayManager.gdm.autoSuspend = false;
  # AC-8 copy-pasta
  services.xserver.displayManager.gdm.banner = ''
    You are accessing a private information system, which includes:
    1) this computer,
    2) this computer network,
    3) all computers connected to this network, and
    4) all devices and storage media attached to this network or to a computer on this network.
    You understand and consent to the following:
    - you may access this information system for authorized use only;
    - you have no reasonable expectation of privacy regarding any communication of data transiting or stored on this information system;
    - at any time and for any lawful purpose, we may monitor, intercept, and search and seize any communication or data transiting or stored on this information system;
    - and any communications or data transiting or stored on this information system may be disclosed or used for any lawful purpose.
  '';

  # Multi-monitor support: Secondary monitor is rotated
  boot.kernelParams = [ "video=HDMI-1:panel_orientation=left_side_up" ];

  # Needed to build aarch64 packages such as raspberry pi images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
