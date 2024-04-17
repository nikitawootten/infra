{ pkgs, lib, config, ... }:
let cfg = config.personal.tmux;
in {
  options.personal.tmux = { enable = lib.mkEnableOption "shell config"; };

  config = lib.mkIf cfg.enable {
    # Draws heavily from https://github.com/dreamsofcode-io/tmux/blob/main/tmux.conf
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      mouse = true;

      extraConfig = ''
        # 256 color support
        set -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"

        # split to CWD
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Use Alt-arrow keys without prefix key to switch panes
        # Does not work within VSCode
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window
      '';

      plugins = with pkgs; [{
        # Provides easy yanking for Linux and MacOS:
        # - <prefix> [ to activate
        # - v to select
        # - C-v to toggle between line and block selection
        # - y to yank to system clipboard
        plugin = tmuxPlugins.yank;
        extraConfig = ''
          # set vi-mode
          set-window-option -g mode-keys vi
          # keybindings
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        '';
      }];
    };
  };
}
