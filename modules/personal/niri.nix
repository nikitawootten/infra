{ self, inputs, ... }:
let
  defaultTheme = pkgs: {
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
in
{
  flake.wrapperModules.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      t = defaultTheme pkgs // config.theme;
      noctaliaIpc = target: fn: [
        "noctalia-shell"
        "ipc"
        "call"
        target
        fn
      ];
      wrappedNoctalia = inputs.nix-wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = {
          bar = {
            position = "bottom";
            widgets = {
              left = [
                {
                  id = "Workspace";
                  showApplications = true;
                  showApplicationsHover = true;
                }
              ];
              center = [
                {
                  id = "SystemMonitor";
                  compactMode = false;
                  usePadding = true;
                  showCpuTemp = false;
                  showDiskUsage = true;
                  showDiskAvailable = true;
                  showNetworkStats = true;
                }
              ];
              right = [
                {
                  id = "MediaMini";
                  maxWidth = 250;
                  showVisualizer = true;
                }
                { id = "Tray"; }
                { id = "KeyboardLayout"; }
                { id = "NotificationHistory"; }
                { id = "KeepAwake"; }
                { id = "Battery"; }
                { id = "Volume"; }
                { id = "Clock"; }
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
              ];
            };
          };
          dock.enabled = false;
          wallpaper.overviewEnabled = true;
          appLauncher = {
            terminalCommand = "ghostty -e";
            enableClipboardHistory = true;
          };
          location = {
            autoLocate = true;
            useFahrenheit = true;
          };
          colorSchemes = {
            predefinedScheme = "Tokyo Night";
            useWallpaperColors = false;
            darkMode = true;
          };
          ui.fontFixed = "JetBrainsMono Nerd Font";
          general.showChangelogOnStartup = false;
          idle = {
            enabled = true;
            screenOffTimeout = 0;
            lockTimeout = 5 * 60;
            suspendTimeout = 6 * 60;
            suspendCommand = "systemctl ${config.idleAction}";
          };
        };
      };
    in
    {
      options.theme = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Color theme overrides, merged on top of defaultTheme";
      };

      options.idleAction = lib.mkOption {
        type = lib.types.str;
        default = "suspend-then-hibernate";
        description = "systemctl sleep verb noctalia runs on idle";
      };

      # Required for `peck`
      config.package = pkgs.niri.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "kiryl";
          repo = "niri";
          rev = "d26ab5f29df670110a91a7e933a743eeaf611978";
          hash = "sha256-3HxntJA2DNg+L94gbM86uGeJqPPWbSX88CjteOmYV0o=";
        };
      });

      config.v2-settings = true;
      config.env.NIXOS_OZONE_WL = "1";
      config.runtimePkgs = [
        wrappedNoctalia
        pkgs.fastfetch
      ];

      config.settings = {
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        spawn-at-startup = [
          [ "noctalia-shell" ]
        ];
        binds = {
          # Basic interaction
          "Mod+Shift+E".quit = _: { };
          "Mod+Shift+Slash".show-hotkey-overlay = _: { };
          "Mod+Shift+Q".close-window = _: { };
          "Mod+D".spawn = noctaliaIpc "launcher" "toggle";
          "Mod+V".spawn = noctaliaIpc "launcher" "clipboard";
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
          "Print".screenshot = _: { };
          "Ctrl+Print".screenshot-screen = _: { };
          "Ctrl+Shift+Print".screenshot-window = _: { };
          "Mod+Alt+L".spawn = noctaliaIpc "lockScreen" "lock";

          "XF86AudioRaiseVolume" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = noctaliaIpc "volume" "increase";
          };
          "XF86AudioLowerVolume" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = noctaliaIpc "volume" "decrease";
          };
          "XF86AudioMute" = _: {
            props = {
              allow-when-locked = true;
              repeat = false;
            };
            content.spawn = noctaliaIpc "volume" "muteOutput";
          };
          "XF86AudioMicMute" = _: {
            props = {
              allow-when-locked = true;
              repeat = false;
            };
            content.spawn = noctaliaIpc "volume" "muteInput";
          };

          "XF86MonBrightnessUp" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = noctaliaIpc "brightness" "increase";
          };
          "XF86MonBrightnessDown" = _: {
            props = {
              allow-when-locked = true;
              repeat = true;
            };
            content.spawn = noctaliaIpc "brightness" "decrease";
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

          "Mod+Shift+N".spawn = noctaliaIpc "notifications" "toggleHistory";
          "Mod+BracketLeft".consume-or-expel-window-left = _: { };
          "Mod+BracketRight".consume-or-expel-window-right = _: { };
        };
        layout.background-color = "transparent";
        layout.border.off = _: { };
        layout.focus-ring = {
          width = 4;
          active-color = t.accent;
          inactive-color = t.muted;
          urgent-color = t.urgent;
        };
        layout.tab-indicator = {
          position = "left";
          gap = 0;
          width = 4;
          length = _: {
            props.total-proportion = 0.5;
          };
          active-color = t.success;
          inactive-color = t.muted;
          urgent-color = t.urgent;
        };
        layout.gaps = 8;
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
          mouse = {
            scroll-factor = 0.5;
          };
          touchpad = {
            natural-scroll = _: { };
            dwt = _: { };
            drag-lock = _: { };
            tap = _: { };
          };
          workspace-auto-back-and-forth = _: { };
        };
        window-rules = [
          {
            geometry-corner-radius = [
              8.0
              8.0
              8.0
              8.0
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
          {
            matches = [
              {
                app-id = "steam";
                title = "^notificationtoasts_\\d+_desktop$";
              }
            ];
            default-floating-position = _: {
              props = {
                x = 10;
                y = 10;
                relative-to = "bottom-right";
              };
            };
            open-focused = false;
          }
        ];
        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-overview-"; } ];
            place-within-backdrop = true;
          }
        ];
        clipboard.disable-primary = _: { };
        prefer-no-csd = _: { };
        # Allows notification actions and window activation from Noctalia
        debug.honor-xdg-activation-with-invalid-serial = _: { };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      _packages.niri = inputs.nix-wrapper-modules.wrappers.niri.wrap {
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
        idleAction = lib.mkOption {
          type = lib.types.str;
          default = "suspend-then-hibernate";
          description = "systemctl sleep verb noctalia runs on idle";
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
            idleAction = config.personal.niri.idleAction;
          };
          peck = inputs.peck.packages.${pkgs.stdenv.hostPlatform.system}.default;
          wallpaper = (defaultTheme pkgs // config.personal.niri.theme).wallpaper;
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

          programs.yubikey-touch-detector.enable = true;

          services.gnome.sushi.enable = true;
          services.gvfs.enable = true;

          # Required by `peck`.
          services.gnome.at-spi2-core.enable = true;

          environment.systemPackages = [
            pkgs.file-roller
            pkgs.nautilus
            pkgs.loupe
            pkgs.pavucontrol
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
                self.homeModules.fonts
                self.homeModules.ghostty
              ];

              services.ssh-agent.enable = true;

              home.file."Pictures/Wallpapers/${wallpaper.name}".source = wallpaper;

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
                  gtk-theme = "Adwaita";
                  toolkit-accessibility = true;
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
