{ lib, config, pkgs, ... }:
let
  # FIDO2 key living on the first Yubikey
  # A note to myself for Arch installs:
  #   "libfido2" is not installed automatically!
  key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIgGx2KcXwXTYHMh5DOLzTq7YIBu0GngrYX9BYiCRnOvAAAABHNzaDo= nikita.wootten@gmail.com";
  cfg = config.personal.git;
in
{
  options.personal.git = {
    enable = lib.mkEnableOption "git config";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = lib.mkDefault true;
      userName = lib.mkDefault "Nikita Wootten";
      userEmail = lib.mkDefault "nikita.wootten@gmail.com";
      ignores = [
        ".DS_Store"
        "*~"
        "*.swp"
        "Thumbs.db"
        "/scratch/" # I often have "scratch" directory for experiments
        ".direnv"
      ];
      extraConfig = {
        fetch.prune = lib.mkDefault true;
        pull.rebase = lib.mkDefault false;
        init.defaultBranch = lib.mkDefault "main";

        # signing
        gpg.format = lib.mkDefault "ssh";
        commit.gpgsign = lib.mkDefault true;
        tag.gpgsign = lib.mkDefault true;
        user.signingKey = lib.mkDefault "key::${key}";
      };
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
      extensions = with pkgs; [
        gh-dash
      ];
    };

    home.packages = with pkgs; [
      gita
    ];

    programs.bash.initExtra = ''
      source ${pkgs.gita}/share/bash-completion/completions/gita
    '';

    programs.zsh.initExtra = ''
      autoload -U +X bashcompinit && bashcompinit
      source ${pkgs.gita}/share/zsh/site-functions/gita
    '';

    home.sessionVariables = {
      # Where I do my work
      GIT_WORKSPACE = "~/Documents/repos";
    };
  };
}
