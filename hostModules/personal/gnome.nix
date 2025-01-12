{ pkgs, lib, config, ... }:
let cfg = config.personal.gnome;
in {
  options.personal.gnome = {
    enable = lib.mkEnableOption "gnome configuration";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [{ personal.gnome.enable = true; }];

    personal.sound.enable = lib.mkDefault true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    programs.dconf.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ];

    environment.systemPackages = with pkgs; [ gnome-tweaks ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
  };
}
