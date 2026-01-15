{ lib, config, ... }:
let
  cfg = config.personal.virtualbox;
in
{
  options.personal.virtualbox = {
    enable = lib.mkEnableOption "Virtualbox";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
    users.users.${config.personal.user.name}.extraGroups = [ "vboxusers" ];
  };
}
