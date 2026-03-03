{ ... }:
{
  flake.modules.homeManager.bridge =
    { lib, config, ... }:
    {
      services.protonmail-bridge.enable = true;

      programs.git.settings.sendemail = {
        smtpServer = lib.mkDefault "127.0.0.1";
        smtpUser = lib.mkDefault config.programs.git.settings.user.email;
        smtpServerPort = lib.mkDefault 1025;
        smtpsslcertpath = ""; # protonmail bridge uses self-signed cert :/
      };
    };
}
