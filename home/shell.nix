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
    enableSyntaxHighlighting = true;
    enableAutosuggestions = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 20000;
      size = 20000;
    };

    initExtra = ''
      # C-x C-e edit command in $VISUAL editor (parity with bash)
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line
      autoload -z edit-command-line

      # Forward/backword word bindings
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Highlight completions on tab
      zstyle ':completion:*' menu select

      # Write to history on every command, but do not read from history
      # Each session will appear to have its own history
      setopt INC_APPEND_HISTORY
    '';
  } // shellCommon;

  programs.bash = { } // shellCommon;

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
    };
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
