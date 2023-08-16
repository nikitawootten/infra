{ lib, config, username, ... }:
let
  cfg = config.personal.virtualbox;
in
{
  options.personal.virtualbox = {
    enable = lib.mkEnableOption "Virtualbox";
  };

  config = lib.mkIf cfg.enable {
    # TODO
    nixpkgs.config.allowUnfree = true;
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
    users.users.${username}.extraGroups = [ "vboxusers" ];
  };
}