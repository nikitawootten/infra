{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.personal.sound;
in
{
  options.personal.sound = {
    enable = lib.mkEnableOption "sound configuration";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    environment.systemPackages = with pkgs; [
      alsa-utils
    ];
  };
}
