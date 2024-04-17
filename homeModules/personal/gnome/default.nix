{ lib, config, ... }:
let cfg = config.personal.gnome;
in {
  options.personal.gnome = { enable = lib.mkEnableOption "gnome config"; };

  config = lib.mkIf cfg.enable {
    dconf = {
      enable = true;
      settings = { "org/gnome/shell".disable-user-extensions = false; };
    };
  };

  imports = [ ./appearance.nix ./extra.nix ./input.nix ];
}
