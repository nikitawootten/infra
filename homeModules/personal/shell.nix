{ pkgs, lib, config, ... }:
let
  shellCommon = {
    enable = true;
    enableCompletion = true;
    # needed for some terminal emulators to set title to current directory
    enableVteIntegration = true;
  };

  # needed for single user installations
  sourceNixSingleUser = ''
    [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';

  cfg = config.personal.shell;
in {
  options.personal.shell = { enable = lib.mkEnableOption "shell config"; };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";

      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      sys = "systemctl";
      sysu = "systemctl --user";

      e = "$EDITOR";
      zfe = "$EDITOR $(fzf)";
    };

    home.sessionPath = [ "$HOME/.local/bin" ];

    home.sessionVariables = {
      GOPATH = "$HOME/go";
      # colored man pages (via https://wiki.archlinux.org/title/Color_output_in_console#Using_less)
      MANPAGER = "less -R --use-color -Dd+r -Du+b";
    };

    programs.zsh = {
      dotDir = ".config/zsh";
      autosuggestion.enable = true;

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 20000;
        size = 20000;
        extended = true;
        share = true;
      };

      initExtra = ''
        # C-x C-e edit command in $VISUAL editor (parity with bash)
        zle -N edit-command-line
        bindkey '^x^e' edit-command-line
        autoload -z edit-command-line

        # C-backspace
        bindkey '^H' backward-kill-word

        # Forward/backword word bindings
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # Highlight completions on tab
        zstyle ':completion:*' menu select
        # And Shift-Tab should cycle backwards
        bindkey '^[[Z' reverse-menu-complete

        ${sourceNixSingleUser}
      '';

      plugins = [{
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }];
    } // shellCommon;

    programs.bash = {
      historyControl = [ "ignoredups" "ignorespace" ];
      initExtra = ''
        # C-backspace
        stty werase \^H

        # Try to get close to ZSH tab completion:

        # If there are multiple matches for completion, Tab should cycle through them
        bind 'TAB:menu-complete'
        # And Shift-Tab should cycle backwards
        bind '"\e[Z": menu-complete-backward'

        # Display a list of the matching files
        bind "set show-all-if-ambiguous on"

        # Perform partial (common) completion on the first Tab press, only start
        # cycling full results on the second Tab press (from bash version 5)
        bind "set menu-complete-display-prefix on"

        ${sourceNixSingleUser}
      '';
    } // shellCommon;

    # packaged bash on MacOS is ancient
    home.packages =
      lib.lists.optionals pkgs.stdenv.isDarwin (with pkgs; [ bashInteractive ]);
  };
}
