{ pkgs, config, lib, ... }:
let cfg = config.services.protonmail-bridge;
in {
  options.services.protonmail-bridge = {
    enable = lib.mkEnableOption "Enable protonmail-bridge";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.protonmail-bridge;
      description = "Protonmail Bridge package";
    };
    enableGitSendEmail = lib.mkEnableOption "Enable git send-email";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.protonmail-bridge = {
      enable = true;
      Unit = {
        Description = "Protonmail Bridge";
        PartOf = "graphical-session.target";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
      Service = {
        Type = "simple";
        ExecStart =
          "${cfg.package}/bin/protonmail-bridge --noninteractive --log-level info";

      };
    };
  } // lib.mkIf (cfg.enable && cfg.enableGitSendEmail) {
    programs.git = {
      package = lib.mkDefault pkgs.gitFull;
      extraConfig = {
        sendemail = {
          smtpServer = "localhost";
          smptPort = lib.mkDefault 1025;
          smtpUser = lib.mkDefault config.programs.git.userEmail;
        };
      };
    };
  };
}
