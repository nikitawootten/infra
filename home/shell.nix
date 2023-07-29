{ pkgs, ... }:
let
  shellCommon = {
    enable = true;
    enableCompletion = true;
    # needed for some terminal emulators to set title to current directory
    enableVteIntegration = true;
  };
in
{
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

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
    # colored man pages (via https://wiki.archlinux.org/title/Color_output_in_console#Using_less)
    MANPAGER = "less -R --use-color -Dd+r -Du+b";
  };

  programs.zsh = {
    dotDir = ".config/zsh";
    enableAutosuggestions = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 20000;
      size = 20000;
      extended = true;
      share = false;
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
    '';

    plugins = [
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
    ];
  } // shellCommon;

  programs.bash = {
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
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
    '';
  } // shellCommon;

  # shells share a common prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[➜](bold green)";
      character.error_symbol = "[✗](bold red)";
      aws.disabled = true;
      battery.disabled = true;
      # warn me when I'm not in zsh
      shell.disabled = false;
      shell.zsh_indicator = "";
      # no nerdfont
      nodejs.symbol = "[⬢](bold green) ";
    };
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
    };
  };

  home.packages = [
    pkgs.bat
  ];
}
