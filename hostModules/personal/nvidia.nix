{ lib, config, ... }:
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
  };
}
