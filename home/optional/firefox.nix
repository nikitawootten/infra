{ ... }:
{
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
}
