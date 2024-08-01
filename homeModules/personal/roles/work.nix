{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.work;
in {
  options.personal.roles.work = {
    enable = lib.mkEnableOption "Work related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      httpie-desktop
      # TODO: re-enable after https://github.com/NixOS/nixpkgs/pull/330789 is merged
      # nomachine-client
      # AWS CLI currently pollutes the user PYTHONPATH, causing issues with virtual environments
      (writeShellScriptBin "aws" ''
        unset PYTHONPATH
        exec ${pkgs.awscli2}/bin/aws "$@"
      '')
      beekeeper-studio
    ];

    xdg.desktopEntries.httpie-desktop = {
      name = "HTTPie Desktop";
      genericName = "HTTP Client";
      exec = "${pkgs.httpie-desktop}/bin/httpie-desktop %u";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
  };
}
