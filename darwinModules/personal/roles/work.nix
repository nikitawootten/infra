{ config, lib, ... }:
let cfg = config.personal.roles.work;
in {
  options.personal.roles.work = {
    enable = lib.mkEnableOption "Work related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    # Enable corresponding home-manager module
    home-manager.sharedModules = [{ personal.roles.work.enable = true; }];

    homebrew.masApps = {
      AppleDeveloper = 640199958;
      TestFlight = 899247664;
    };
    homebrew.brews = [ "xcode-build-server" ];
    homebrew.casks = [
      "figma"
      "google-chrome"
      "notion"
      "slack"
      "zoom"
      "httpie-desktop"
      "sf-symbols"
      "android-studio"
      "android-platform-tools"
      "proxyman"
      "claude"
    ];
  };
}
