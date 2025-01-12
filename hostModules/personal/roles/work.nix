{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.work;
in {
  options.personal.roles.work = {
    enable = lib.mkEnableOption "Work related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [{ personal.roles.work.enable = true; }];

    personal.docker.enable = true;
    personal.printing.enable = true;

    # Android development
    programs.adb.enable = true;
    users.users.${config.personal.user.name}.extraGroups = [ "adbusers" "kvm" ];
    environment.systemPackages = [ pkgs.android-studio ];
  };
}
