{ lib, config, username, ... }:
let
  cfg = config.personal.adb;
in
{
  options.personal.adb = {
    enable = lib.mkEnableOption "adb";
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.${username}.extraGroups = ["adbusers"];
  };
}
