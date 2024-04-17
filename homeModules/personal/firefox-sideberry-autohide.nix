{ lib, config, ... }:
let cfg = config.personal.firefox.sideberry-autohide;
in {
  options.personal.firefox.sideberry-autohide = {
    enable = lib.mkEnableOption "sideberry autohide";
    preface = lib.mkOption {
      type = lib.types.str;
      description = "The window preface to hide the window on";
      default = "‏‏‎ ‎";
    };
    profiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The profiles to write to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles = lib.attrsets.genAttrs cfg.profiles (_: {
      userChrome = ''
        #main-window #TabsToolbar {
          height: 40px !important;
          overflow: hidden;
          transition: height 0.2s ease-in 0s !important;
        }
        #main-window[titlepreface*="${cfg.preface}"] #TabsToolbar {
          height: 0 !important;
          min-height: 0 !important;
        }
        #main-window[titlepreface*="${cfg.preface}"] #tabbrowser-tabs {
          position: fixed;
          z-index: 0 !important;
        }
        #main-window[titlepreface*="${cfg.preface}"] .tab-stack {
          visibility: hidden;
        }
        #main-window[titlepreface*="${cfg.preface}"] #toolbar {
          min-height: 0;
        }
        #main-window[titlepreface*="${cfg.preface}"] #sidebar-header {
          visibility: hidden;
          height: 0px;
          padding: 0px !important;
          border: 0px !important;
        }
        #main-window[titlepreface*="${cfg.preface}"] #titlebar {
          height: 0px;
        }
      '';
    });
  };
}
