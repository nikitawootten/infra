{ inputs, self, ... }:
{
  flake.nixosModules.niri-noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # GIT_WORKSPACE holds a literal `~`, so expand it before use.
      workspace = "ws=$(eval echo \"\${GIT_WORKSPACE:-~/Documents/workspace}\")";
      # Git repos in the workspace, allowing one level of nesting (<group>/<subproject>).
      listRepos = "${workspace}; find -L \"$ws\" -mindepth 2 -maxdepth 3 -name .git -printf '%h\\n' 2>/dev/null | sed \"s|^$ws/||\" | sort";
      # Open the selected repo in a new terminal, optionally running a command in it.
      openRepo = args: "${workspace}; exec ghostty --working-directory=\"$ws/{selection}\"${args}";
    in
    {
      options.personal.niri.idleAction = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "suspend-then-hibernate";
        description = "systemctl sleep verb noctalia runs on idle, or null to only blank the screens";
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

                launcher.dmenu.entry = {
                  proj = {
                    label = "Projects";
                    prefix = "proj";
                    glyph = "git-branch";
                    global = false;
                    command = listRepos;
                    exec = openRepo "";
                  };
                  edit = {
                    label = "Edit project";
                    prefix = "edit";
                    glyph = "pencil";
                    global = false;
                    command = listRepos;
                    exec = openRepo " -e \"\${EDITOR:-nvim}\" .";
                  };
                };
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

              idle.behavior = {
                lock = {
                  enabled = true;
                  action = "lock";
                  timeout = 5 * 60;
                };
                screen-off = {
                  enabled = config.personal.niri.idleAction == null;
                  action = "screen_off";
                  timeout = 6 * 60;
                };
              }
              // lib.optionalAttrs (config.personal.niri.idleAction != null) {
                suspend = {
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
