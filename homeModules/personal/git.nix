{ lib, config, pkgs, keys, ... }:
let
  # FIDO2 key living on the first Yubikey
  # A note to myself for Arch installs:
  #   "libfido2" is not installed automatically!
  cfg = config.personal.git;
in
{
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
      aliases = {
        fpush = "push --force-with-lease";
      };
      extraConfig = {
        fetch.prune = lib.mkDefault true;
        pull.rebase = lib.mkDefault false;
        init.defaultBranch = lib.mkDefault "main";
        push.autoSetupRemote = lib.mkDefault true;
        rerere.enabled = lib.mkDefault true;

        # signing
        gpg.format = lib.mkDefault "ssh";
        commit.gpgsign = lib.mkDefault true;
        tag.gpgsign = lib.mkDefault true;
        user.signingKey = lib.mkDefault cfg.signingKey;
      };
      lfs.enable = true;
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

    home.sessionVariables = {
      # Where I do my work
      GIT_WORKSPACE = "~/Documents/workspace";
    };
  };
}
