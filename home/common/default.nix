{ lib, ... }:
{
  imports = [
    ./allowUnfreeRegexes.nix
    ./direnv.nix
    ./editor.nix
    ./git.nix
    ./misc-utils.nix
    ./shell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./upgrade-diff.nix
  ];

  upgrade-diff.enable = lib.mkDefault true;
}
