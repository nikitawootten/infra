{ pkgs, lib, config, ... }:
let cfg = config.personal.kde;
in {
  options.personal.kde = { enable = lib.mkEnableOption "kde configuration"; };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    programs.dconf.enable = true;

    personal.sound.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      kdePackages.discover
      kdePackages.plasma-vault
      kdePackages.krdc
    ];

    # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
