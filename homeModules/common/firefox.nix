{ lib, config, ... }:
let
  cfg = config.personal.firefox;
in
{
  options.personal.firefox = {
    enable = lib.mkEnableOption "firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          isDefault = true;
          settings = {
            "privacy.donottrackheader.enabled" = true;
            "extensions.pocket.enabled" = false;
            "browser.tabs.firefox-view" = false;

            "browser.startup.page" = 3;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          };
        };
      };
    };
    home.sessionVariables.BROWSER = "firefox";
  };
}