{ lib, config, pkgs, ... }:
let
  cfg = config.personal.nvidia;
in
{
  options.personal.nvidia = {
    enable = lib.mkEnableOption "nvidia configuration";
    headless = lib.mkOption {
      type = lib.types.bool;
      description = "If true, enable NVidia settings";
      default = true;
    };
    betaDriver = lib.mkEnableOption "enable beta driver";
    suspend = lib.mkEnableOption "enable experimental suspend";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = lib.mkDefault true;
      open = lib.mkDefault false;
      nvidiaSettings = lib.mkDefault (!cfg.headless);
      package = lib.mkDefault (
        if cfg.betaDriver
          then config.boot.kernelPackages.nvidiaPackages.beta
          else config.boot.kernelPackages.nvidiaPackages.stable
        );
      powerManagement.enable = lib.mkDefault cfg.suspend;
    };

    boot.kernelParams = lib.lists.optional cfg.betaDriver "nvidia.NVreg_PreserveVideoMemoryAllocations=1";

    virtualisation.docker.enableNvidia = true;

    # NVIDIA HW Accel, via https://github.com/Moskas/nixos-config
    environment.variables = {
      # Necessary to correctly enable va-api (video codec hardware
      # acceleration). If this isn't set, the libvdpau backend will be
      # picked, and that one doesn't work with most things, including
      # Firefox.
      LIBVA_DRIVER_NAME = "nvidia";
      # Required to run the correct GBM backend for nvidia GPUs on wayland
      GBM_BACKEND = "nvidia-drm";
      # Apparently, without this nouveau may attempt to be used instead
      # (despite it being blacklisted)
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Hardware cursors are currently broken on nvidia
      WLR_NO_HARDWARE_CURSORS = "1";

      # Required to use va-api it in Firefox. See
      # https://github.com/elFarto/nvidia-vaapi-driver/issues/96
      MOZ_DISABLE_RDD_SANDBOX = "1";
      # It appears that the normal rendering mode is broken on recent
      # nvidia drivers:
      # https://github.com/elFarto/nvidia-vaapi-driver/issues/213#issuecomment-1585584038
      NVD_BACKEND = "direct";
      # Required for firefox 98+, see:
      # https://github.com/elFarto/nvidia-vaapi-driver#firefox
      EGL_PLATFORM = "wayland";
    };
  };
}
