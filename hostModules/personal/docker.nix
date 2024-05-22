{ lib, config, ... }:
let cfg = config.personal.docker;
in {
  options.personal.docker = {
    enable = lib.mkEnableOption "docker configuration";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.users.${config.personal.user.name}.extraGroups = [ "docker" ];
  };
}
