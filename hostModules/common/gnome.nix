{ pkgs, lib, config, ... }:
let
  cfg = config.personal.gnome;
in
{
  options.personal.gnome = {
    enable = lib.mkEnableOption "gnome configuration";
  };

  config = lib.mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Counter-intuitively required in order for Nix-managed gnome-extensions to be picked up
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome.gnome-boxes
    ];

    environment.gnome.excludePackages = with pkgs.gnome; [
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ];

    personal.sound.enable = lib.mkDefault true;
  };

}
