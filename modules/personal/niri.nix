{ self, inputs, ... }:
{
  flake.wrapperModules.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      defaultTheme = {
        wallpaper = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/atraxsrc/tokyonight-wallpapers/main/bin_original.png";
          sha256 = "sha256-scfp1OJwvkooZi5kHBE7/NVVroXo0dzwwl6ND+AokZQ=";
        };
        bg = "#1a1b26";
        "bg-dark" = "#16161e";
        fg = "#c0caf5";
        accent = "#7aa2f7";
        "accent-alt" = "#bb9af7";
        urgent = "#f7768e";
        success = "#9ece6a";
        warning = "#e0af68";
        info = "#7dcfff";
        muted = "#565f89";
        orange = "#ff9e64";
        teal = "#73dacb";
        surface = "#3d59a1";
        black = "#15161e";
      };
      t = defaultTheme // config.theme;
      wrappedSwaylock = inputs.nix-wrapper-modules.wrappers.swaylock.wrap {
        inherit pkgs;
        package = pkgs.swaylock-effects;
        settings = {
          clock = true;
          show-failed-attempts = true;
          indicator = true;
          ignore-empty-password = true;
          color = t.bg;
          line-color = t.bg;
          ring-color = t.surface;
          key-hl-color = t.accent;
          bs-hl-color = t.urgent;
          inside-color = "${t.bg}cc";
          text-color = t.fg;
          ring-ver-color = t.accent;
          inside-ver-color = "${t.bg}cc";
          ring-wrong-color = t.urgent;
          inside-wrong-color = "${t.bg}cc";
          ring-clear-color = t.warning;
          inside-clear-color = "${t.bg}cc";
          text-clear-color = t.fg;
        }
        // {
          image = "${t.wallpaper}";
        };
      };
      wrappedSwayidle = inputs.nix-wrapper-modules.wrappers.swayidle.wrap {
        inherit pkgs;
        timeouts = [
          {
            timeout = 5 * 60;
            command = "${wrappedSwaylock}/bin/swaylock -f";
          }
          {
            timeout = 6 * 60;
            command = "systemctl suspend-then-hibernate";
          }
        ];
        events.before-sleep = "${wrappedSwaylock}/bin/swaylock -f";
      };
      wrappedWaybar = inputs.nix-wrapper-modules.wrappers.waybar.wrap {
        inherit pkgs;
        settings = {
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
              ""
              ""
              ""
              ""
              ""
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
        };
        "style.css".content = ''
          * {
            font-family: monospace;
            font-size: 13px;
          }
          window#waybar {
            background-color: ${t."bg-dark"};
            color: ${t.fg};
            border-top: 2px solid ${t.surface};
          }
          #workspaces button {
            color: ${t.muted};
            padding: 0 5px;
          }
          #workspaces button.active {
            color: ${t.accent};
          }
          #workspaces button.urgent {
            color: ${t.urgent};
          }
          #clock, #battery, #tray, #language {
            color: ${t.fg};
            padding: 0 8px;
          }
          #battery.warning {
            color: ${t.warning};
          }
          #battery.critical {
            color: ${t.urgent};
          }
        '';
      };
      wrappedTofi = inputs.nix-wrapper-modules.wrappers.tofi.wrap {
        inherit pkgs;
        settings = {
          width = "100%";
          height = "100%";
          num-results = 5;
          border-width = 0;
          outline-width = 0;
          padding-left = "35%";
          padding-top = "35%";
          result-spacing = 25;
          background-color = "${t.black}AA";
          text-color = t.fg;
          prompt-color = t.accent;
          selection-color = t.accent;
          selection-background = "${t.surface}88";
        };
      };
    in
    {
      options.theme = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Color theme overrides, merged on top of defaultTheme";
      };

      config.v2-settings = true;
      config.env.NIXOS_OZONE_WL = "1";
      config.extraPackages = [
        wrappedWaybar
        wrappedSwayidle
        wrappedSwaylock
        wrappedTofi
        pkgs.swaynotificationcenter
        pkgs.swayosd
        pkgs.swaybg
        pkgs.pasystray
        pkgs.networkmanagerapplet
      ];

      config.settings = {
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        spawn-at-startup = [
          [ "waybar" ]
          [ "swayidle" ]
          [ "swaync" ]
          [ "swayosd-server" ]
          [
            "swaybg"
            "-c"
            "${t.bg}"
            "-i"
            "${t.wallpaper}"
            "-m"
            "fill"
          ]
          [ "pasystray" ]
          [ "nm-applet" ]
        ];
        binds = {
          # Basic interaction
          "Mod+Shift+E".quit = _: { };
          "Mod+Shift+Slash".show-hotkey-overlay = _: { };
          "Mod+Shift+Q".close-window = _: { };
          "Mod+D".spawn = [
            "tofi-drun"
            "--drun-launch=true"
            "--fuzzy-match=true"
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
          "Print".screenshot = _: { };
          "Ctrl+Print".screenshot-screen = _: { };
          "Ctrl+Shift+Print".screenshot-window = _: { };
          "Mod+Alt+L".spawn = "swaylock";

          "XF86AudioRaiseVolume" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = [
              "swayosd-client"
              "--output-volume"
              "raise"
            ];
          };
          "XF86AudioLowerVolume" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = [
              "swayosd-client"
              "--output-volume"
              "lower"
            ];
          };
          "XF86AudioMute" = _: {
            props = {
              allow-when-locked = true;
              repeat = false;
            };
            content.spawn = [
              "swayosd-client"
              "--output-volume"
              "mute-toggle"
            ];
          };
          "XF86AudioMicMute" = _: {
            props = {
              allow-when-locked = true;
              repeat = false;
            };
            content.spawn = [
              "swayosd-client"
              "--input-volume"
              "mute-toggle"
            ];
          };

          "XF86MonBrightnessUp" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = [
              "swayosd-client"
              "--brightness"
              "raise"
            ];
          };
          "XF86MonBrightnessDown" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = [
              "swayosd-client"
              "--brightness"
              "lower"
            ];
          };

          # Movement
          "Mod+Left".focus-column-or-monitor-left = _: { };
          "Mod+Down".focus-window-or-workspace-down = _: { };
          "Mod+Up".focus-window-or-workspace-up = _: { };
          "Mod+Right".focus-column-or-monitor-right = _: { };
          "Mod+H".focus-column-or-monitor-left = _: { };
          "Mod+J".focus-window-or-workspace-down = _: { };
          "Mod+K".focus-window-or-workspace-up = _: { };
          "Mod+L".focus-column-or-monitor-right = _: { };

          "Mod+Ctrl+Left".move-column-left-or-to-monitor-left = _: { };
          "Mod+Ctrl+Down".move-window-down-or-to-workspace-down = _: { };
          "Mod+Ctrl+Up".move-window-up-or-to-workspace-up = _: { };
          "Mod+Ctrl+Right".move-column-right-or-to-monitor-right = _: { };
          "Mod+Ctrl+H".move-column-left-or-to-monitor-left = _: { };
          "Mod+Ctrl+J".move-window-down-or-to-workspace-down = _: { };
          "Mod+Ctrl+K".move-window-up-or-to-workspace-up = _: { };
          "Mod+Ctrl+L".move-column-right-or-to-monitor-right = _: { };

          "Mod+Home".focus-column-first = _: { };
          "Mod+End".focus-column-last = _: { };
          "Mod+Ctrl+Home".move-column-to-first = _: { };
          "Mod+Ctrl+End".move-column-to-last = _: { };

          "Mod+WheelScrollDown" = _: {
            props.cooldown-ms = 150;
            content.focus-workspace-down = _: { };
          };
          "Mod+WheelScrollUp" = _: {
            props.cooldown-ms = 150;
            content.focus-workspace-up = _: { };
          };
          "Mod+Ctrl+WheelScrollDown" = _: {
            props.cooldown-ms = 150;
            content.move-column-to-workspace-down = _: { };
          };
          "Mod+Ctrl+WheelScrollUp" = _: {
            props.cooldown-ms = 150;
            content.move-column-to-workspace-up = _: { };
          };

          "Mod+WheelScrollRight".focus-column-right = _: { };
          "Mod+WheelScrollLeft".focus-column-left = _: { };
          "Mod+Ctrl+WheelScrollRight".move-column-right = _: { };
          "Mod+Ctrl+WheelScrollLeft".move-column-left = _: { };
          "Mod+Shift+WheelScrollDown".focus-column-right = _: { };
          "Mod+Shift+WheelScrollUp".focus-column-left = _: { };
          "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = _: { };
          "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = _: { };

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
          "Mod+Comma".consume-window-into-column = _: { };
          "Mod+Period".expel-window-from-column = _: { };
          "Mod+R".switch-preset-column-width = _: { };
          "Mod+Shift+R".reset-window-height = _: { };
          "Mod+F".maximize-column = _: { };
          "Mod+Shift+F".fullscreen-window = _: { };
          "Mod+Ctrl+F".expand-column-to-available-width = _: { };
          "Mod+C".center-column = _: { };
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";
          "Mod+W".toggle-column-tabbed-display = _: { };

          "Mod+Grave".toggle-overview = _: { };

          "Mod+Tab".switch-focus-between-floating-and-tiling = _: { };
          "Mod+Shift+Tab".toggle-window-floating = _: { };

          "Mod+Shift+N".spawn = [
            "swaync-client"
            "-op"
          ];
          "Mod+BracketLeft".consume-or-expel-window-left = _: { };
          "Mod+BracketRight".consume-or-expel-window-right = _: { };
        };
        layout.background-color = "transparent";
        layout.border = {
          active-color = t.accent;
          inactive-color = t.muted;
        };
        layout.focus-ring.off = _: { };
        input = {
          focus-follows-mouse = _: {
            props.max-scroll-amount = "10%";
          };
          keyboard = {
            xkb = {
              layout = "us,ru";
              options = "grp:win_space_toggle,caps:escape";
            };
          };
          touchpad = {
            natural-scroll = _: { };
            dwt = _: { };
            drag-lock = _: { };
          };
          workspace-auto-back-and-forth = _: { };
        };
        window-rules = [
          {
            geometry-corner-radius = [
              14.0
              14.0
              14.0
              14.0
            ];
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
            default-floating-position = _: {
              props = {
                x = 32;
                y = 32;
                relative-to = "bottom-right";
              };
            };
            default-column-width.fixed = 480;
            default-window-height.fixed = 270;
          }
        ];
        layer-rules = [
          {
            matches = [ { namespace = "^wallpaper$"; } ];
            place-within-backdrop = true;
          }
        ];
        clipboard.disable-primary = _: { };
        prefer-no-csd = _: { };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.niri = inputs.nix-wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [ self.wrapperModules.niri ];
      };
    };

  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.sound
      ];

      options.personal.niri = {
        extraSettings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Host-specific niri settings merged with defaults";
        };
        theme = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Theme overrides merged with defaults from the wrapper module";
        };
        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "The wrapped niri package";
        };
      };

      config =
        let
          wrappedNiri = inputs.nix-wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [ self.wrapperModules.niri ];
            theme = config.personal.niri.theme;
            settings = config.personal.niri.extraSettings;
          };
        in
        {
          personal.niri.package = wrappedNiri;

          programs.niri = {
            enable = true;
            package = config.personal.niri.package;
          };

          services.xserver.enable = true;
          services.displayManager.gdm.enable = true;
          security.pam.services.gdm.enableGnomeKeyring = true;

          services.gnome.sushi.enable = true;
          services.gvfs.enable = true;

          environment.systemPackages = [
            pkgs.file-roller
            pkgs.nautilus
            pkgs.pavucontrol
          ];

          hardware.brillo.enable = true;

          # https://github.com/Supreeeme/xwayland-satellite/issues/150#issuecomment-2847677630
          programs.steam.package = pkgs.steam.override {
            extraArgs = "-system-composer";
          };

          home-manager.sharedModules = [
            {
              imports = [
                self.homeModules.fonts
                self.homeModules.ghostty
              ];

              services.ssh-agent.enable = true;

              home.packages = [
                pkgs.networkmanagerapplet
              ];

              dconf.settings = {
                "org/gnome/desktop/interface" = {
                  icon-theme = "Adwaita";
                  gtk-theme = "Adwaita";
                };
              };

              gtk = {
                enable = true;
                theme = {
                  name = "Adwaita";
                };
                gtk4.theme = null;
                iconTheme = {
                  package = pkgs.adwaita-icon-theme;
                  name = "Adwaita";
                };
              };
            }
          ];
        };
    };
}
