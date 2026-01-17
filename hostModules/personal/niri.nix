{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.personal.niri;
in
{
  imports = [ inputs.niri.nixosModules.niri ];

  options.personal.niri = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    personal.sound.enable = lib.mkDefault true;
    services.dbus = {
      enable = true;
    };
    services.gnome.gnome-keyring.enable = true;
    services.gnome.sushi.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      nautilus
      swaybg
      file-roller
    ];

    hardware.brillo.enable = true;

    # https://github.com/Supreeeme/xwayland-satellite/issues/150#issuecomment-2847677630
    programs.steam.package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };

    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        {
          personal.fonts.enable = true;

          programs.niri = {
            settings = {
              spawn-at-startup = [
                {
                  command = [
                    "systemctl"
                    "--user"
                    "start"
                    "waybar.service"
                  ];
                }
                {
                  command = [
                    "${pkgs.swaybg}/bin/swaybg"
                    "-i"
                    "${config.stylix.image}"
                  ];
                }
              ];
              xwayland-satellite.enable = true;
              xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;
              binds = with config.lib.niri.actions; {
                # Basic interaction
                "Mod+Shift+E".action = quit;
                "Mod+Shift+Slash".action = show-hotkey-overlay;
                "Mod+Shift+Q".action = close-window;
                "Mod+D".action = spawn [
                  "tofi-drun"
                  "--drun-launch=true"
                  "--fuzzy-match=true"
                ];
                "Mod+T".action = spawn [
                  "nautilus"
                  "--new-window"
                ];
                "Mod+Return".action = spawn [
                  "ghostty"
                  "+new-window"
                ];
                "Mod+Shift+Return".action = spawn [
                  "ghostty"
                  "--title=floatme"
                ];
                "Print".action.screenshot = [ ];
                "Ctrl+Print".action.screenshot-screen = [ ];
                "Alt+Print".action.screenshot-window = [ ];
                "Mod+Shift+P".action = power-off-monitors;
                "Mod+Alt+L".action = spawn "swaylock";

                "XF86AudioRaiseVolume" = {
                  action.spawn = [
                    "swayosd-client"
                    "--output-volume"
                    "raise"
                  ];
                  allow-when-locked = true;
                  repeat = true;
                };
                "XF86AudioLowerVolume" = {
                  action.spawn = [
                    "swayosd-client"
                    "--output-volume"
                    "lower"
                  ];
                  allow-when-locked = true;
                  repeat = true;
                };
                "XF86AudioMute" = {
                  action.spawn = [
                    "swayosd-client"
                    "--output-volume"
                    "mute-toggle"
                  ];
                  allow-when-locked = true;
                  repeat = false;
                };
                "XF86AudioMicMute" = {
                  action.spawn = [
                    "swayosd-client"
                    "--input-volume"
                    "mute-toggle"
                  ];
                  allow-when-locked = true;
                  repeat = false;
                };

                "XF86MonBrightnessUp" = {
                  action.spawn = [
                    "swayosd-client"
                    "--brightness"
                    "raise"
                  ];
                  allow-when-locked = true;
                  repeat = true;
                };
                "XF86MonBrightnessDown" = {
                  action.spawn = [
                    "swayosd-client"
                    "--brightness"
                    "lower"
                  ];
                  allow-when-locked = true;
                  repeat = true;
                };

                # Movement
                "Mod+Left".action = focus-column-left;
                "Mod+Down".action = focus-window-down;
                "Mod+Up".action = focus-window-up;
                "Mod+Right".action = focus-column-right;
                "Mod+H".action = focus-column-left;
                "Mod+J".action = focus-window-down;
                "Mod+K".action = focus-window-up;
                "Mod+L".action = focus-column-right;

                "Mod+Ctrl+Left".action = move-column-left;
                "Mod+Ctrl+Down".action = move-window-down;
                "Mod+Ctrl+Up".action = move-window-up;
                "Mod+Ctrl+Right".action = move-column-right;
                "Mod+Ctrl+H".action = move-column-left;
                "Mod+Ctrl+J".action = move-window-down;
                "Mod+Ctrl+K".action = move-window-up;
                "Mod+Ctrl+L".action = move-column-right;

                "Mod+Home".action = focus-column-first;
                "Mod+End".action = focus-column-last;
                "Mod+Ctrl+Home".action = move-column-to-first;
                "Mod+Ctrl+End".action = move-column-to-last;

                # Monitor movement
                "Mod+Shift+Left".action = focus-monitor-left;
                "Mod+Shift+Down".action = focus-monitor-down;
                "Mod+Shift+Up".action = focus-monitor-up;
                "Mod+Shift+Right".action = focus-monitor-right;
                "Mod+Shift+H".action = focus-monitor-left;
                "Mod+Shift+J".action = focus-monitor-down;
                "Mod+Shift+K".action = focus-monitor-up;
                "Mod+Shift+L".action = focus-monitor-right;

                "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
                "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
                "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
                "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
                "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
                "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
                "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
                "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

                # Workspace
                "Mod+Page_Down".action = focus-workspace-down;
                "Mod+Page_Up".action = focus-workspace-up;
                "Mod+U".action = focus-workspace-down;
                "Mod+I".action = focus-workspace-up;
                "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
                "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
                "Mod+Ctrl+U".action = move-column-to-workspace-down;
                "Mod+Ctrl+I".action = move-column-to-workspace-up;

                "Mod+Shift+Page_Down".action = move-workspace-down;
                "Mod+Shift+Page_Up".action = move-workspace-up;
                "Mod+Shift+U".action = move-workspace-down;
                "Mod+Shift+I".action = move-workspace-up;

                "Mod+WheelScrollDown".action = focus-workspace-down;
                "Mod+WheelScrollDown".cooldown-ms = 150;
                "Mod+WheelScrollUp".action = focus-workspace-up;
                "Mod+WheelScrollUp".cooldown-ms = 150;
                "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
                "Mod+Ctrl+WheelScrollDown".cooldown-ms = 150;
                "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
                "Mod+Ctrl+WheelScrollUp".cooldown-ms = 150;

                "Mod+WheelScrollRight".action = focus-column-right;
                "Mod+WheelScrollLeft".action = focus-column-left;
                "Mod+Ctrl+WheelScrollRight".action = move-column-right;
                "Mod+Ctrl+WheelScrollLeft".action = move-column-left;
                "Mod+Shift+WheelScrollDown".action = focus-column-right;
                "Mod+Shift+WheelScrollUp".action = focus-column-left;
                "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
                "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

                "Mod+1".action = focus-workspace 1;
                "Mod+2".action = focus-workspace 2;
                "Mod+3".action = focus-workspace 3;
                "Mod+4".action = focus-workspace 4;
                "Mod+5".action = focus-workspace 5;
                "Mod+6".action = focus-workspace 6;
                "Mod+7".action = focus-workspace 7;
                "Mod+8".action = focus-workspace 8;
                "Mod+9".action = focus-workspace 9;
                "Mod+Ctrl+1".action.move-column-to-workspace = 1;
                "Mod+Ctrl+2".action.move-column-to-workspace = 2;
                "Mod+Ctrl+3".action.move-column-to-workspace = 3;
                "Mod+Ctrl+4".action.move-column-to-workspace = 4;
                "Mod+Ctrl+5".action.move-column-to-workspace = 5;
                "Mod+Ctrl+6".action.move-column-to-workspace = 6;
                "Mod+Ctrl+7".action.move-column-to-workspace = 7;
                "Mod+Ctrl+8".action.move-column-to-workspace = 8;
                "Mod+Ctrl+9".action.move-column-to-workspace = 9;

                # Column
                "Mod+Comma".action = consume-window-into-column;
                "Mod+Period".action = expel-window-from-column;
                "Mod+R".action = switch-preset-column-width;
                "Mod+Shift+R".action = reset-window-height;
                "Mod+F".action = maximize-column;
                "Mod+Shift+F".action = fullscreen-window;
                "Mod+C".action = center-column;
                "Mod+Minus".action = set-column-width "-10%";
                "Mod+Equal".action = set-column-width "+10%";
                "Mod+Shift+Minus".action = set-window-height "-10%";
                "Mod+Shift+Equal".action = set-window-height "+10%";
                "Mod+W".action = toggle-column-tabbed-display;

                "Mod+Grave".action = toggle-overview;

                "Mod+Tab".action = switch-focus-between-floating-and-tiling;
                "Mod+Shift+Tab".action = toggle-window-floating;

                "Mod+Shift+N".action = spawn "swaync-client" "-op";
              };
              layout.background-color = "transparent";
              input = {
                focus-follows-mouse = {
                  enable = true;
                  max-scroll-amount = "10%";
                };
                keyboard = {
                  xkb = {
                    layout = "us,ru";
                    options = "grp:win_space_toggle,caps:escape";
                  };
                };
                touchpad = {
                  natural-scroll = true;
                  dwt = true;
                  drag-lock = true;
                };
                workspace-auto-back-and-forth = true;
              };
              window-rules = [
                {
                  geometry-corner-radius.bottom-left = 14.0;
                  geometry-corner-radius.bottom-right = 14.0;
                  geometry-corner-radius.top-left = 14.0;
                  geometry-corner-radius.top-right = 14.0;
                  clip-to-geometry = true;
                }
                {
                  matches = [ { is-active = false; } ];
                  opacity = 0.95;
                }
                {
                  matches = [
                    { title = "floatme"; }
                    { title = "Authentication Required"; }
                  ];
                  open-floating = true;
                }
                {
                  matches = [
                    {
                      app-id = "firefox";
                      title = "Picture-in-Picture";
                    }
                  ];
                  open-floating = true;
                  default-floating-position = {
                    x = 32;
                    y = 32;
                    relative-to = "bottom-right";
                  };
                  default-column-width = {
                    fixed = 480;
                  };
                  default-window-height = {
                    fixed = 270;
                  };
                }
              ];
              layer-rules = [
                {
                  matches = [ { namespace = "^wallpaper$"; } ];
                  place-within-backdrop = true;
                }
              ];
              clipboard.disable-primary = true;
              prefer-no-csd = true;
            };
          };

          services.swaync = {
            enable = true;
          };
          services.swayosd = {
            enable = true;
          };

          programs.waybar = {
            enable = true;
            systemd.enable = true;
            settings = [
              {
                height = 20;
                margin = "5";
                layer = "top";
                position = "bottom";
                tray = {
                  spacing = 15;
                };
                modules-left = [
                  "niri/workspaces"
                ];
                modules-center = [ ];
                modules-right = [
                  "privacy"
                  "tray"
                  "niri/language"
                  "battery"
                  "clock"
                ];

                battery = {
                  format = "{capacity}% {icon}";
                  format-icons = [
                    ""
                    ""
                    ""
                    ""
                    ""
                  ];
                };
                clock = {
                  format = "{:%a %d %b %H:%M}";
                  format-alt = "Week {:%V of %Y}";
                  tooltip-format = "<tt><small>{calendar}</small></tt>";
                  calendar = {
                    mode = "month";
                    mode-mon-col = 3;
                    weeks-pos = "left";
                    on-scroll = 1;
                    on-click-right = "mode";
                  };
                };
              }
            ];
          };

          services.swayidle = {
            enable = true;
            timeouts = [
              {
                timeout = 5 * 60;
                command = "${lib.getExe pkgs.swaylock-effects} -f";
              }
              {
                timeout = 6 * 60;
                command = "systemctl suspend-then-hibernate";
              }
            ];
            events.before-sleep = "${lib.getExe pkgs.swaylock-effects} -f";
          };

          programs.swaylock = {
            enable = true;
            package = pkgs.swaylock-effects;
            settings = {
              clock = true;
              show-failed-attempts = true;
              indicator = true;
              ignore-empty-password = true;
            };
          };

          programs.tofi = {
            enable = true;
            # Via https://github.com/shreyas-sha3/niri-dots/blob/main/.config/tofi/config
            settings = {
              width = "100%";
              height = "100%";
              num-results = 5;
              border-width = 0;
              outline-width = 0;
              padding-left = "35%";
              padding-top = "35%";
              result-spacing = 25;
              text-color = config.lib.stylix.colors.base04;
              selection-color = config.lib.stylix.colors.base16;
              background-color = "#000A";
            };
          };
          stylix.targets.tofi.colors.enable = false;

          personal.ghostty.enable = true;

          services.ssh-agent.enable = true;
        }
      )
    ];
  };
}
