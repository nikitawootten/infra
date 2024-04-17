{ config, lib, pkgs, username, ... }:
let cfg = config.personal.zsa;
in {
  options.personal.zsa = {
    enable = lib.mkEnableOption "zsa udev rules + wally";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = with pkgs; [ zsa-udev-rules ];
    environment.systemPackages = with pkgs; [ wally-cli ];

    # User must be a part of "plugdev" to use wally without root
    users.groups.plugdev = { };
    users.users.${username}.extraGroups = [ "plugdev" ];
  };
}
