{ inputs, lib, ... }: {
  imports = [
    ./gnome
    ./roles
    ./cluster-admin.nix
    ./darwin.nix
    ./direnv.nix
    ./editor.nix
    ./firefox-gnome-theme.nix
    ./firefox-sideberry-autohide.nix
    ./firefox.nix
    ./fonts.nix
    ./git.nix
    ./kitty.nix
    ./misc-utils.nix
    ./sectools.nix
    ./shell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./upgrade-diff.nix
    ./vscode.nix
    ./zellij.nix
    inputs.nix-index-database.hmModules.nix-index
  ];

  programs.home-manager.enable = lib.mkForce true;

  personal.direnv.enable = lib.mkDefault true;
  personal.editor.enable = lib.mkDefault true;
  personal.git.enable = lib.mkDefault true;
  personal.misc-utils.enable = lib.mkDefault true;
  personal.shell.enable = lib.mkDefault true;
  personal.starship.enable = lib.mkDefault true;
  personal.tmux.enable = lib.mkDefault true;
  personal.upgrade-diff.enable = lib.mkDefault true;
}
