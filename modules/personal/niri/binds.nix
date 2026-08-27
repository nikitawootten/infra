{ ... }:
let
  noctaliaMsg =
    command:
    [
      "noctalia"
      "msg"
    ]
    ++ command;
in
{
  flake.homeModules.niri-binds = {
    wayland.windowManager.niri.settings.binds = {
      # Basic interaction
      "Mod+Shift+E".quit = { };
      "Mod+Shift+Slash".show-hotkey-overlay = { };
      "Mod+Shift+Q".close-window = { };
      "Mod+D".spawn = noctaliaMsg [
        "panel-toggle"
        "launcher"
      ];
      "Mod+V".spawn = noctaliaMsg [
        "panel-toggle"
        "clipboard"
      ];
      "Mod+T".spawn = [
        "nautilus"
        "--new-window"
      ];
      "Mod+Return".spawn = [
        "ghostty"
        "+new-window"
      ];
      "Mod+Shift+Return".spawn = [
        "ghostty"
        "--title=floatme"
      ];
      "Mod+Slash".spawn = [
        "peck"
        "activate"
      ];
      "Print".screenshot = { };
      "Ctrl+Print".screenshot-screen = { };
      "Ctrl+Shift+Print".screenshot-window = { };
      "Mod+Alt+L".spawn = noctaliaMsg [
        "session"
        "lock"
      ];

      "XF86AudioRaiseVolume" = {
        _props = {
          allow-when-locked = true;
          repeat = true;
        };
        spawn = noctaliaMsg [ "volume-up" ];
      };
      "XF86AudioLowerVolume" = {
        _props = {
          allow-when-locked = true;
          repeat = true;
        };
        spawn = noctaliaMsg [ "volume-down" ];
      };
      "XF86AudioMute" = {
        _props = {
          allow-when-locked = true;
          repeat = false;
        };
        spawn = noctaliaMsg [ "volume-mute" ];
      };
      "XF86AudioMicMute" = {
        _props = {
          allow-when-locked = true;
          repeat = false;
        };
        spawn = noctaliaMsg [ "mic-mute" ];
      };

      "XF86MonBrightnessUp" = {
        _props = {
          allow-when-locked = true;
          repeat = true;
        };
        spawn = noctaliaMsg [ "brightness-up" ];
      };
      "XF86MonBrightnessDown" = {
        _props = {
          allow-when-locked = true;
          repeat = true;
        };
        spawn = noctaliaMsg [ "brightness-down" ];
      };

      # Movement
      "Mod+Left".focus-column-or-monitor-left = { };
      "Mod+Down".focus-window-or-workspace-down = { };
      "Mod+Up".focus-window-or-workspace-up = { };
      "Mod+Right".focus-column-or-monitor-right = { };
      "Mod+H".focus-column-or-monitor-left = { };
      "Mod+J".focus-window-or-workspace-down = { };
      "Mod+K".focus-window-or-workspace-up = { };
      "Mod+L".focus-column-or-monitor-right = { };

      "Mod+Ctrl+Left".move-column-left-or-to-monitor-left = { };
      "Mod+Ctrl+Down".move-window-down-or-to-workspace-down = { };
      "Mod+Ctrl+Up".move-window-up-or-to-workspace-up = { };
      "Mod+Ctrl+Right".move-column-right-or-to-monitor-right = { };
      "Mod+Ctrl+H".move-column-left-or-to-monitor-left = { };
      "Mod+Ctrl+J".move-window-down-or-to-workspace-down = { };
      "Mod+Ctrl+K".move-window-up-or-to-workspace-up = { };
      "Mod+Ctrl+L".move-column-right-or-to-monitor-right = { };

      "Mod+Home".focus-column-first = { };
      "Mod+End".focus-column-last = { };
      "Mod+Ctrl+Home".move-column-to-first = { };
      "Mod+Ctrl+End".move-column-to-last = { };

      "Mod+WheelScrollDown" = {
        _props.cooldown-ms = 150;
        focus-workspace-down = { };
      };
      "Mod+WheelScrollUp" = {
        _props.cooldown-ms = 150;
        focus-workspace-up = { };
      };
      "Mod+Ctrl+WheelScrollDown" = {
        _props.cooldown-ms = 150;
        move-column-to-workspace-down = { };
      };
      "Mod+Ctrl+WheelScrollUp" = {
        _props.cooldown-ms = 150;
        move-column-to-workspace-up = { };
      };

      "Mod+WheelScrollRight".focus-column-right = { };
      "Mod+WheelScrollLeft".focus-column-left = { };
      "Mod+Ctrl+WheelScrollRight".move-column-right = { };
      "Mod+Ctrl+WheelScrollLeft".move-column-left = { };
      "Mod+Shift+WheelScrollDown".focus-column-right = { };
      "Mod+Shift+WheelScrollUp".focus-column-left = { };
      "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
      "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };

      "Mod+1".focus-workspace = 1;
      "Mod+2".focus-workspace = 2;
      "Mod+3".focus-workspace = 3;
      "Mod+4".focus-workspace = 4;
      "Mod+5".focus-workspace = 5;
      "Mod+6".focus-workspace = 6;
      "Mod+7".focus-workspace = 7;
      "Mod+8".focus-workspace = 8;
      "Mod+9".focus-workspace = 9;
      "Mod+Ctrl+1".move-column-to-workspace = 1;
      "Mod+Ctrl+2".move-column-to-workspace = 2;
      "Mod+Ctrl+3".move-column-to-workspace = 3;
      "Mod+Ctrl+4".move-column-to-workspace = 4;
      "Mod+Ctrl+5".move-column-to-workspace = 5;
      "Mod+Ctrl+6".move-column-to-workspace = 6;
      "Mod+Ctrl+7".move-column-to-workspace = 7;
      "Mod+Ctrl+8".move-column-to-workspace = 8;
      "Mod+Ctrl+9".move-column-to-workspace = 9;

      # Column
      "Mod+Comma".consume-window-into-column = { };
      "Mod+Period".expel-window-from-column = { };
      "Mod+R".switch-preset-column-width = { };
      "Mod+Shift+R".reset-window-height = { };
      "Mod+F".maximize-column = { };
      "Mod+Shift+F".fullscreen-window = { };
      "Mod+Ctrl+F".expand-column-to-available-width = { };
      "Mod+C".center-column = { };
      "Mod+Minus".set-column-width = "-10%";
      "Mod+Equal".set-column-width = "+10%";
      "Mod+Shift+Minus".set-window-height = "-10%";
      "Mod+Shift+Equal".set-window-height = "+10%";
      "Mod+W".toggle-column-tabbed-display = { };

      "Mod+Grave".toggle-overview = { };

      "Mod+Tab".switch-focus-between-floating-and-tiling = { };
      "Mod+Shift+Tab".toggle-window-floating = { };

      "Mod+Shift+N".spawn = noctaliaMsg [
        "panel-toggle"
        "control-center"
        "notifications"
      ];
      "Mod+BracketLeft".consume-or-expel-window-left = { };
      "Mod+BracketRight".consume-or-expel-window-right = { };
    };
  };
}
