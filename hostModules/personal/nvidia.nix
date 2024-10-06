{ lib, config, pkgs, ... }:
let cfg = config.personal.nvidia;
in {
  options.personal.nvidia = {
    enable = lib.mkEnableOption "nvidia configuration";
    headless = lib.mkOption {
      type = lib.types.bool;
      description = "If not true, enable NVidia settings";
      default = true;
    };
    betaDriver = lib.mkEnableOption "enable beta driver";
    suspend = lib.mkEnableOption "enable experimental suspend";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ vaapiVdpau ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      open = lib.mkDefault true;
      modesetting.enable = lib.mkDefault true;
      nvidiaSettings = lib.mkDefault (!cfg.headless);
      package = lib.mkDefault (if cfg.betaDriver then
        config.boot.kernelPackages.nvidiaPackages.beta
      else
        config.boot.kernelPackages.nvidiaPackages.stable);
      powerManagement.enable = lib.mkDefault cfg.suspend;
    };

    boot.kernelParams = lib.lists.optionals cfg.betaDriver [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_EnableGpuFirmware=0"
    ];

    hardware.nvidia-container-toolkit.enable = true;
  };
}
