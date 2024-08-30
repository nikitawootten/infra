{ pkgs, lib, config, inputs, ... }:
let cfg = config.personal.niri;
in {
  options.personal.niri = { enable = lib.mkEnableOption "Niri"; };

  imports = [ inputs.niri.nixosModules.niri ];

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.file-roller.enable = true;

    personal.sound.enable = lib.mkDefault true;

    services.dbus = { enable = true; };

    services.gnome.gnome-keyring.enable = true;
    services.gnome.sushi.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [ nautilus swaybg ];

    services.flatpak.overrides.global = {
      # Force Wayland by default
      Context.sockets = [ "wayland" "!x11" "!fallback-x11" ];
    };

    home-manager.sharedModules = [{ personal.niri.enable = true; }];
  };
}
