{ lib, config, ... }:
let
  cfg = config.personal.flatpak;
in
{
  options.personal.flatpak = {
    enable = lib.mkEnableOption "flatpak & flatpak installs";
    remotes = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "The flatpak remotes to enable (name -> URL)";
    };
    apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The flatpak apps to install";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    # systemd.services.flatpak_nixos_appinstall = {
    #   description = "Management hook to ensure";
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network.target" ];
    # };
  };
}
