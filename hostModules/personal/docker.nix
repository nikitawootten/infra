{ lib, config, username, ... }:
let cfg = config.personal.docker;
in {
  options.personal.docker = {
    enable = lib.mkEnableOption "docker configuration";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.users.${username}.extraGroups = [ "docker" ];
  };
}
