{ lib, config, ... }:
let cfg = config.personal.bridge;
in {
  options.personal.bridge = {
    enable =
      lib.mkEnableOption "ProtonMail bridge + git-send-email integration";
  };

  config = lib.mkIf cfg.enable {
    services.protonmail-bridge.enable = true;

    programs.git.settings.sendemail = {
      smtpServer = lib.mkDefault "127.0.0.1";
      smtpUser = lib.mkDefault config.programs.git.userEmail;
      smtpServerPort = lib.mkDefault 1025;
      smtpsslcertpath = ""; # protonmail bridge uses self-signed cert :/
    };
  };
}
