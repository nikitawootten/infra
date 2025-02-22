{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.security;
in {
  options.personal.roles.security = {
    enable = lib.mkEnableOption "Security tools";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [{ personal.roles.security.enable = true; }];

    users.users.${config.personal.user.name}.extraGroups = [ "wireshark" ];
    programs.wireshark.enable = lib.mkForce true;
    programs.wireshark.package = lib.mkDefault pkgs.wireshark;
  };
}
