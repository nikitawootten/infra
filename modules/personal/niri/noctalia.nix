{ inputs, self, ... }:
{
  flake.nixosModules.niri-noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.personal.niri.idleAction = lib.mkOption {
        type = lib.types.str;
        default = "suspend-then-hibernate";
        description = "systemctl sleep verb noctalia runs on idle";
      };

      config.home-manager.sharedModules = [
        {
          imports = [ inputs.noctalia.homeModules.default ];

          programs.noctalia = {
            enable = true;
            systemd.enable = true;
            settings = {
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
                  # Path must match `noctalia_base16` in modules/editor/config/lua/plugins/colorscheme.lua.
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
          };

          systemd.user.tmpfiles.rules = [ "d %h/Pictures/Wallpapers 0755 - - -" ];
        }
      ];
    };
}
