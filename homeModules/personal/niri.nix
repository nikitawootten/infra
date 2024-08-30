{ pkgs, lib, config, ... }:
let cfg = config.personal.niri;
in {
  options.personal.niri = { enable = lib.mkEnableOption "Niri"; };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      settings = {
        spawn-at-startup = [
          {
            command = [ "systemctl" "--user" "reset-failed" "waybar.service" ];
          }
          {
            command =
              [ "${pkgs.swaybg}/bin/swaybg" "-i" "${config.stylix.image}" ];
          }
        ];
        binds = with config.lib.niri.actions; {
          # Basic interaction
          "Mod+Shift+E".action = quit;
          "Mod+Shift+Slash".action = show-hotkey-overlay;
          "Mod+Q".action = close-window;
          "Mod+D".action = spawn "fuzzel";
          "Mod+T".action = spawn "kitty";
          "Print".action = screenshot;
          "Ctrl+Print".action = screenshot-screen;
          "Alt+Print".action = screenshot-window;
          "Mod+Shift+P".action = power-off-monitors;
          "Mod+Alt+L".action = spawn "swaylock";

          "XF86AudioRaiseVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
          "XF86AudioLowerVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
          "XF86AudioMute".action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          "XF86AudioMicMute".action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];

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
          "Mod+Ctrl+1".action = move-column-to-workspace 1;
          "Mod+Ctrl+2".action = move-column-to-workspace 2;
          "Mod+Ctrl+3".action = move-column-to-workspace 3;
          "Mod+Ctrl+4".action = move-column-to-workspace 4;
          "Mod+Ctrl+5".action = move-column-to-workspace 5;
          "Mod+Ctrl+6".action = move-column-to-workspace 6;
          "Mod+Ctrl+7".action = move-column-to-workspace 7;
          "Mod+Ctrl+8".action = move-column-to-workspace 8;
          "Mod+Ctrl+9".action = move-column-to-workspace 9;

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
        };
        input = {
          focus-follows-mouse.enable = true;
          keyboard = {
            xkb = {
              layout = "us,ru";
              options = "grp:win_space_toggle";
            };
          };
          touchpad.natural-scroll = true;
        };
      };
    };

    # TODO: Move the below configuration to a "WM common" module

    services.mako = { enable = true; };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = [{
        height = 30;
        layer = "top";
        position = "bottom";
        tray = { spacing = 10; };
        modules-left = [ ];
        modules-center = [ "clock" ];
        modules-right =
          [ "network" "cpu" "memory" "tempurature" "tray" "battery" ];

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
      }];
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "swaylock";
        }
        {
          event = "lock";
          command = "swaylock";
        }
      ];
      timeouts = [
        {
          timeout = 5 * 60;
          command = "swaylock";
        }
        {
          timeout = 30 * 60;
          command = "systemctl suspend";
        }
      ];
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

    programs.fuzzel.enable = true;

    personal.kitty.enable = true;

    services.ssh-agent.enable = true;
  };
}
