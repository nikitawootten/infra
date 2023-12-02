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
      modesetting.enable = true;
      open = false;
      nvidiaSettings = !cfg.headless;
      package = if cfg.betaDriver
        then config.boot.kernelPackages.nvidiaPackages.beta
        else config.boot.kernelPackages.nvidiaPackages.stable;
    };

    virtualisation.docker.enableNvidia = true;
  };
}
