{ lib, pkgs, ... }:
let
  # FIDO2 key living on the first Yubikey
  # A note to myself for Arch installs:
  #   "libfido2" is not installed automatically!
  key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIgGx2KcXwXTYHMh5DOLzTq7YIBu0GngrYX9BYiCRnOvAAAABHNzaDo= nikita.wootten@gmail.com";
in
{
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

  home.packages = with pkgs; [
    gh
  ];

  home.sessionVariables = {
    # Where I do my work
    GIT_WORKSPACE = "~/Documents/repos";
  };
}
