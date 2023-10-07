{ pkgs, lib, config, ... }:
let
  cfg = config.personal.firefox;
in
{
  options.personal.firefox = {
    enable = lib.mkEnableOption "firefox";
  };


  config = lib.mkIf cfg.enable {
    # needed for speech synthesis
    home.packages = with pkgs; [
      speechd
    ];

    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          isDefault = true;
          settings = {
            # DO NOT TRACK
            "privacy.donottrackheader.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.partition.network_state.ocsp_cache" = true;

            "dom.security.https_only_mode" = true;

            # DO NOT TELEMETRY
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;

            # DO NOT EXPERIMENT
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;

            # DO NOT POCKET
            "extensions.pocket.enabled" = false;

            "browser.tabs.firefox-view" = false;

            # DO NOT SPONSOR
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