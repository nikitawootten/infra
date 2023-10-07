{ lib, config, ... }:
let
  cfg = config.personal.nvidia;
in
{
  options.personal.nvidia = {
    enable = lib.mkEnableOption "nvidia configuration";
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
      nvidiaSettings = false;
    };

    virtualisation.docker.enableNvidia = true;
  };
}