{ ... }:
let
  esc = builtins.fromJSON ''"\u001b"'';
in
{
  flake.homeModules.zed =
    { pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;

        mutableUserSettings = false;
        mutableUserKeymaps = false;

        extensions = [
          "dockerfile"
          "git-firefly"
          "helm"
          "html"
          "kotlin"
          "lua"
          "macos-classic"
          "make"
          "nix"
          "sql"
          "swift"
          "tokyo-night"
          "toml"
          "xml"
        ];

        userSettings = {
          theme = {
            mode = if pkgs.stdenv.hostPlatform.isDarwin then "light" else "dark";
            light = "macOS Classic Light";
            dark = "Tokyo Night";
          };
          icon_theme = "Zed (Default)";

          ui_font_family = "JetBrains Mono";
          ui_font_size = 14;
          buffer_font_family = "JetBrains Mono";
          buffer_font_size = 14;
          agent_ui_font_size = 14;
          terminal = {
            font_family = "JetBrainsMono Nerd Font Mono";
            font_features.calt = true;
            font_size = 14;
          };

          vim_mode = true;
          vim.use_system_clipboard = "never";
          relative_line_numbers = "enabled";
          scroll_beyond_last_line = "vertical_scroll_margin";
          minimap.show = "auto";
          colorize_brackets = true;
          inlay_hints.enabled = true;
          diagnostics.inline.enabled = true;
          tabs.file_icons = true;
          which_key = {
            enabled = true;
            delay_ms = 300;
          };
          cli_default_open_behavior = "new_window";

          project_panel = {
            dock = "left";
            hide_hidden = false;
            hide_root = true;
          };
          outline_panel.dock = "left";
          collaboration_panel.dock = "left";
          git_panel = {
            dock = "left";
            group_by = "staging";
          };
          agent.dock = "right";

          agent_servers = {
            opencode.type = "registry";
            claude-acp = {
              type = "registry";
              default_config_options = {
                effort = "high";
                model = "opus";
                mode = "acceptEdits";
              };
            };
          };
          edit_predictions.provider = "zed";

          load_direnv = "direct";
          languages = {
            Python.language_servers = [ "basedpyright" ];
            Nix.language_servers = [
              "nixd"
              "!nil"
            ];
          };

          ssh_connections = [
            {
              host = "hades";
              projects = [
                { paths = [ "/home/nikita" ]; }
                { paths = [ "/home/nikita/workspace/nixpkgs" ]; }
              ];
            }
          ];

          telemetry = {
            diagnostics = false;
            metrics = false;
          };
        };

        userKeymaps = [
          {
            context = "vim_mode == normal";
            bindings = {
              "space space" = "file_finder::Toggle";
              "space f f" = "file_finder::Toggle";
              "space f g" = "text_finder::Toggle";
              "space f b" = "tab_switcher::ToggleAll";
              "space shift-g l" = "debugger::Start";
              "space shift-g r" = "debugger::Restart";
              "space shift-g b" = "editor::ToggleBreakpoint";
              "space shift-g c" = "debugger::Continue";
              "space shift-g h" = "debugger::Pause";
              "space shift-g i" = "debugger::StepInto";
              "space shift-g o" = "debugger::StepOut";
              "space shift-g n" = "debugger::StepOver";
              "space shift-g ctrl-l" = "editor::EditLogBreakpoint";
            };
          }
          {
            context = "Terminal";
            bindings = {
              "shift-enter" = [
                "terminal::SendText"
                "${esc}\r"
              ];
              "ctrl-w h" = "workspace::ActivatePaneLeft";
              "ctrl-w j" = "workspace::ActivatePaneDown";
              "ctrl-w k" = "workspace::ActivatePaneUp";
              "ctrl-w l" = "workspace::ActivatePaneRight";
            };
          }
          {
            context = "ProjectPanel";
            bindings = {
              "ctrl-w h" = "workspace::ActivatePaneLeft";
              "ctrl-w j" = "workspace::ActivatePaneDown";
              "ctrl-w k" = "workspace::ActivatePaneUp";
              "ctrl-w l" = "workspace::ActivatePaneRight";
            };
          }
        ];
      };
    };
}
