{ pkgs, lib, username, ... }:
{
  users.users.${username}.extraGroups = [ "wireshark" ];
  programs.wireshark.enable = lib.mkForce true;
  programs.wireshark.package = lib.mkDefault pkgs.wireshark;
}
