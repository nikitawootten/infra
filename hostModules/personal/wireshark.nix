{ pkgs, lib, config, username, ... }:
let cfg = config.personal.wireshark;
in {
  options.personal.wireshark = {
    enable = lib.mkEnableOption "wireshark configuration";
  };

  config = lib.mkIf cfg.enable {
    users.users.${username}.extraGroups = [ "wireshark" ];
    programs.wireshark.enable = lib.mkForce true;
    programs.wireshark.package = lib.mkDefault pkgs.wireshark;
  };
}
