{ pkgs, lib, config, ... }:
let cfg = config.personal.firefox;
in {
  options.personal.firefox = { enable = lib.mkEnableOption "firefox"; };

  config = lib.mkIf cfg.enable {
    # needed for speech synthesis (only on linux)
    home.packages = lib.lists.optional pkgs.stdenv.isLinux pkgs.speechd;

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
            "toolkit.telemetry.server" = "data:,";
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "browser.tabs.crashReporting.sendReport" = false;
            "devtools.onboarding.telemetry.logged" = false;

            # DO NOT EXPERIMENT
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;

            # DO NOT POCKET
            "browser.newtabpage.activity-stream.section.highlights.includePocket" =
              false;
            "extensions.pocket.enabled" = false;

            "browser.tabs.firefox-view" = false;
            "browser.tabs.firefox-view-next" = false;

            # DO NOT SPONSOR
            "browser.startup.page" = 3;
            "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" =
              false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" =
              false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

            # MISC
            "browser.aboutConfig.showWarning" = false;
            "middlemouse.paste" = false;
            "general.smoothScroll" = true;
          };

          # Via https://github.com/LudovicoPiero/dotfiles/blob/main/cells/workstations/homeProfiles/firefox/__search.nix
          search = {
            default = "Google";
            order = [ "Google" "DuckDuckGo" ];
            force = true;
            engines = {
              "GitHub" = {
                urls = [{
                  template =
                    "https://github.com/search?q={searchTerms}&type=code";
                }];
                definedAliases = [ "gh" ];
              };

              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];

                icon =
                  "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "np" ];
              };

              "Home-Manager" = {
                urls = [{
                  template = "https://home-manager-options.extranix.com";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                    {
                      name = "release";
                      value = "master";
                    }
                  ];
                }];
                definedAliases = [ "hm" ];
              };

              "NixOS Options" = {
                urls = [{
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];

                icon =
                  "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "no" ];
              };

              "NixOS Wiki" = {
                urls =
                  [{ template = "https://wiki.nixos.org/wiki/{searchTerms}"; }];
                icon =
                  "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "nw" ];
              };

              "YouTube" = {
                urls = [{
                  template =
                    "https://www.youtube.com/results?search_query={searchTerms}";
                }];
                definedAliases = [ "yt" ];
              };

              "Bing".metaData.hidden = true;
              "Google".metaData.alias = "g";
              "DuckDuckGo".metaData.alias = "d";
            };
          };
        };
      };
    };
    home.sessionVariables.BROWSER = "firefox";

    stylix.targets.firefox.firefoxGnomeTheme.enable =
      lib.mkDefault config.personal.gnome.enable;
    stylix.targets.firefox.profileNames = [ "default" ];
  };
}
