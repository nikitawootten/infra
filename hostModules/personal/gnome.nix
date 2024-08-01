{ pkgs, lib, config, ... }:
let cfg = config.personal.gnome;
in {
  options.personal.gnome = {
    enable = lib.mkEnableOption "gnome configuration";
  };

  config = lib.mkIf cfg.enable {
    personal.sound.enable = lib.mkDefault true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.dconf.enable = true;

    environment.gnome.excludePackages = with pkgs.gnome; [
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ];

    environment.systemPackages = with pkgs; [ gnome-tweaks ];

    # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
