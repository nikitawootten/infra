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
    homebrew.brews =
      [ "swiftlint" "xcbeautify" "xcode-build-server" "swift-format" ];
    homebrew.casks = [
      "figma"
      "google-chrome"
      "notion"
      "slack"
      "zoom"
      "httpie"
      "sf-symbols"
      "android-studio"
      "android-platform-tools"
      "proxyman"
    ];
  };
}
