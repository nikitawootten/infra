{ lib, config, pkgs, keys, ... }:
let
  # FIDO2 key living on the first Yubikey
  # A note to myself for Arch installs:
  #   "libfido2" is not installed automatically!
  cfg = config.personal.git;
in {
  options.personal.git = {
    enable = lib.mkEnableOption "git config";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Nikita Wootten";
      description = "Name to use for git commits";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "me@nikita.computer";
      description = "Email to use for git commits";
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
      default = "key::${keys.nikita_yubikey_1}";
      description = "SSH key to use for git signing";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = lib.mkDefault true;
      userName = lib.mkDefault cfg.userName;
      userEmail = lib.mkDefault cfg.userEmail;
      ignores = [
        ".DS_Store"
        "*~"
        "*.swp"
        "Thumbs.db"
        "/scratch/" # I often have "scratch" directory for experiments
        ".direnv"
      ];
      aliases = { fpush = "push --force-with-lease"; };
      signing = {
        format = lib.mkDefault "ssh";
        signByDefault = lib.mkDefault true;
        key = lib.mkDefault cfg.signingKey;
      };
      maintenance.enable = lib.mkDefault true;
      extraConfig = {
        fetch.prune = lib.mkDefault true;
        fetch.pruneTags = lib.mkDefault true;
        fetch.all = lib.mkDefault true;
        pull.rebase = lib.mkDefault false;
        init.defaultBranch = lib.mkDefault "main";
        push.autoSetupRemote = lib.mkDefault true;
        rerere.enabled = lib.mkDefault true;

        # Rewrite GitHub HTTPS remotes as SSH remotes
        # Note: disabled for now, has unintended side effects
        # url."ssh://git@github.com/".insteadOf = "https://github.com/";

        column.ui = lib.mkDefault "auto";
        branch.sort = lib.mkDefault "-committerdate";
        tag.sort = lib.mkDefault "version:refname";

        diff.algorithm = lib.mkDefault "histogram";
        diff.colorMoved = lib.mkDefault "plain";
        diff.mnemonicPrefix = lib.mkDefault true;
        diff.renames = lib.mkDefault true;

        help.autocorrect = lib.mkDefault "prompt";
        commit.verbose = lib.mkDefault true;
      };
      lfs.enable = true;
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
      extensions = with pkgs; [ gh-dash ];
    };

    home.sessionVariables = {
      # Where I do my work
      GIT_WORKSPACE = "~/Documents/workspace";
    };
  };
}
