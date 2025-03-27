{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.work;
in {
  options.personal.roles.work = {
    enable = lib.mkEnableOption "Work related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [ awscli2 redis ] ++ lib.lists.optionals pkgs.stdenv.isLinux [
        httpie-desktop
        beekeeper-studio
        protonmail-desktop
      ];

    personal.cluster-admin.enable = lib.mkDefault true;
    personal.vscode.enable = lib.mkDefault true;
    personal.firefox.enable = lib.mkDefault true;
  };
}
