{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      noctaliaMsg =
        command:
        [
          "noctalia"
          "msg"
        ]
        ++ command;

      noctaliaSettings = {
        shell = {
          clipboard_enabled = true;
          launch_apps_as_systemd_services = true;
          settings_show_advanced = true;
          niri_overview_type_to_launch_enabled = true;
          screen_time_enabled = true;
          password_style = "random";
          polkit_agent = true;
        };

        theme = {
          mode = "auto";
          source = "wallpaper";
          builtin = "Tokyo-Night";
          templates = {
            builtin_ids = [
              "gtk3"
              "gtk4"
              "ghostty"
              "niri"
              "qt"
            ];
            # Path must match `noctalia_base16` in modules/editor/config/init.lua.
            user.nvim-base16 = {
              input_path = "${self.noctaliaTemplates.nvim-base16}";
              output_path = "~/.local/state/nvim/noctalia-base16.lua";
              post_hook = "${lib.getExe' pkgs.procps "pkill"} -SIGUSR1 -x nvim";
            };
          };
        };

        wallpaper = {
          enabled = true;
          directory = "~/Pictures/Wallpapers";
        };
        backdrop.enabled = true;

        location.auto_locate = true;
        weather = {
          enabled = true;
          unit = "imperial";
        };

        dock.enabled = false;

        idle = {
          behavior.lock = {
            enabled = true;
            action = "lock";
            timeout = 5 * 60;
          };
          behavior.screen-off.enabled = false;
          behavior.suspend = {
            enabled = true;
            action = "command";
            command = "systemctl ${config.personal.niri.idleAction}";
            timeout = 6 * 60;
          };
        };

        bar.main = {
          position = "bottom";
          # Square off the bottom corners and run the bar edge to edge.
          margin_ends = 0;
          radius_bottom_left = 0;
          radius_bottom_right = 0;
          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "cpu"
            "ram"
            "disk"
          ];
          end = [
            "media"
            "privacy"
            "tray"
            "keyboard_layout"
            "notifications"
            "battery"
            "volume"
            "clock"
            "control-center"
          ];
        };

        widget = {
          cpu = {
            type = "sysmon";
            stat = "cpu_usage";
            visualization = "graph";
            show_value = false;
          };
          ram = {
            type = "sysmon";
            stat = "ram_used";
            visualization = "graph";
            show_value = false;
          };
          disk = {
            type = "sysmon";
            stat = "disk_free";
            path = "/";
            visualization = "none";
          };
          battery.show_label = false;
          media = {
            max_length = 250;
            hide_when_no_media = true;
          };
          privacy.hide_inactive = true;
          tray.drawer = true;
        };
      };

      baseSettings = {
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        binds = {
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
        layout.background-color = "transparent";
        layout.border.off = { };
        layout.focus-ring.width = 4;
        layout.tab-indicator = {
          position = "left";
          gap = 0;
          width = 4;
          length._props.total-proportion = 0.5;
        };
        layout.gaps = 8;
        input = {
          focus-follows-mouse._props.max-scroll-amount = "10%";
          keyboard = {
            xkb = {
              layout = "us,ru";
              options = "grp:win_space_toggle,caps:escape";
            };
          };
          mouse = {
            scroll-factor = 0.5;
          };
          touchpad = {
            natural-scroll = { };
            dwt = { };
            drag-lock = { };
            tap = { };
          };
          workspace-auto-back-and-forth = { };
        };
        clipboard.disable-primary = { };
        prefer-no-csd = { };
        # Allows notification actions and window activation from Noctalia
        debug.honor-xdg-activation-with-invalid-serial = { };
        _children = [
          {
            window-rule = {
              geometry-corner-radius = [
                8.0
                8.0
                8.0
                8.0
              ];
              clip-to-geometry = true;
            };
          }
          {
            window-rule = {
              _children = [ { match._props.is-active = false; } ];
              opacity = 0.95;
            };
          }
          {
            window-rule = {
              _children = [
                { match._props.title = "floatme"; }
                { match._props.title = "Authentication Required"; }
              ];
              open-floating = true;
            };
          }
          {
            window-rule = {
              _children = [
                {
                  match._props = {
                    app-id = "firefox";
                    title = "Picture-in-Picture";
                  };
                }
              ];
              open-floating = true;
              default-floating-position._props = {
                x = 32;
                y = 32;
                relative-to = "bottom-right";
              };
              default-column-width.fixed = 480;
              default-window-height.fixed = 270;
            };
          }
          {
            window-rule = {
              _children = [
                {
                  match._props = {
                    app-id = "steam";
                    title = "^notificationtoasts_\\d+_desktop$";
                  };
                }
              ];
              default-floating-position._props = {
                x = 10;
                y = 10;
                relative-to = "bottom-right";
              };
              open-focused = false;
            };
          }
          {
            window-rule = {
              _children = [ { match._props.app-id = "dev.noctalia.Noctalia"; } ];
              open-floating = true;
            };
          }
          {
            layer-rule = {
              _children = [ { match._props.namespace = "^noctalia-backdrop"; } ];
              place-within-backdrop = true;
            };
          }
        ];
      };
    in
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
        self.nixosModules.sound
      ];

      options.personal.niri = {
        extraSettings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = ''
            Host-specific niri settings, merged with the defaults. Uses
            home-manager's KDL dialect: `_props` for node properties, `_args`
            for positional arguments and `_children` for repeated nodes such as
            `output`.
          '';
        };
        greeterSettings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = ''
            Host-specific `greeter.toml` settings, merged over the defaults.
            Mainly `output.{layout,scales,transforms}`: the greeter's bundled
            wlroots compositor does not pick up the kernel `panel_orientation`
            quirk that niri honours, so rotated panels must be spelled out.
          '';
        };
        idleAction = lib.mkOption {
          type = lib.types.str;
          default = "suspend-then-hibernate";
          description = "systemctl sleep verb noctalia runs on idle";
        };
        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "The niri package in use";
        };
      };

      config =
        let
          peck = inputs.peck.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          # Required for `peck`
          personal.niri.package = pkgs.niri.overrideAttrs (_: {
            src = pkgs.fetchFromGitHub {
              owner = "kiryl";
              repo = "niri";
              rev = "d26ab5f29df670110a91a7e933a743eeaf611978";
              hash = "sha256-3HxntJA2DNg+L94gbM86uGeJqPPWbSX88CjteOmYV0o=";
            };
          });

          programs.niri = {
            enable = true;
            package = config.personal.niri.package;
          };
          environment.sessionVariables.NIXOS_OZONE_WL = "1";

          programs.noctalia-greeter = {
            enable = true;
            settings = lib.recursiveUpdate {
              session.default = "Niri";
              user.default = config.personal.user.name;
              appearance = {
                scheme = "Tokyo-Night";
                theme_mode = "dark";
                password_style = "random";
              };
              keyboard = {
                layout = "us,ru";
                options = "grp:win_space_toggle,caps:escape";
              };
              cursor = {
                theme = "Adwaita";
                size = 24;
              };
            } config.personal.niri.greeterSettings;
          };

          programs.yubikey-touch-detector.enable = true;

          services.gnome.sushi.enable = true;
          services.gvfs.enable = true;

          # Required by `peck`.
          services.gnome.at-spi2-core.enable = true;

          environment.systemPackages = [
            pkgs.file-roller
            pkgs.nautilus
            pkgs.papers
            pkgs.simple-scan
            pkgs.loupe
            pkgs.showtime
            pkgs.snapshot
            pkgs.pavucontrol
            pkgs.glib
            peck
          ];

          hardware.brillo.enable = true;

          services.upower.enable = true;
          services.power-profiles-daemon.enable = true;

          # https://github.com/Supreeeme/xwayland-satellite/issues/150#issuecomment-2847677630
          programs.steam.package = pkgs.steam.override {
            extraArgs = "-system-composer";
          };

          home-manager.sharedModules = [
            {
              imports = [
                inputs.noctalia.homeModules.default
                self.homeModules.fonts
                self.homeModules.ghostty
              ];

              programs.noctalia = {
                enable = true;
                systemd.enable = true;
                settings = noctaliaSettings;
              };

              wayland.windowManager.niri = {
                enable = true;
                # Shared with the system-level `programs.niri`, which already
                # installs the session and its systemd units.
                package = config.personal.niri.package;
                systemd.enable = false;
                portalPackage = null;
                xwaylandSatellitePackage = null;
                settings = lib.mkMerge [
                  baseSettings
                  config.personal.niri.extraSettings
                ];
                extraConfig = ''
                  include optional=true "~/.config/niri/noctalia.kdl"
                '';
              };

              home.packages = [ pkgs.fastfetch ];

              services.ssh-agent.enable = true;

              services.udiskie.enable = true;

              systemd.user.tmpfiles.rules = [ "d %h/Pictures/Wallpapers 0755 - - -" ];

              home.file.".face".source = pkgs.fetchurl {
                url = "https://avatars.githubusercontent.com/u/8916363";
                sha256 = "sha256-8hO46RoG4rCrB+bkIBAx/AU16jyQ6T9s5kopO6KLFo0=";
              };

              systemd.user.services.peck = {
                Unit = {
                  Description = "peck activation daemon";
                  After = [
                    "graphical-session.target"
                    "at-spi-dbus-bus.service"
                  ];
                  Wants = [ "at-spi-dbus-bus.service" ];
                  PartOf = [ "graphical-session.target" ];
                };
                Service = {
                  ExecStart = "${lib.getExe peck} daemon";
                  Restart = "on-failure";
                  RestartSec = 2;
                };
                Install.WantedBy = [ "graphical-session.target" ];
              };

              dconf.settings = {
                "org/gnome/desktop/interface" = {
                  icon-theme = "Adwaita";
                  toolkit-accessibility = true;
                };
              };

              gtk = {
                enable = true;
                # Noctalia's GTK hook swaps this between adw-gtk3 and adw-gtk3-dark.
                theme = {
                  package = pkgs.adw-gtk3;
                  name = "adw-gtk3";
                };
                # GTK4 apps ignore Noctalia's colors if a theme is set here.
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
