{ self, inputs, ... }:
{
  flake.homeModules.personal =
    { lib, ... }:
    {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
        self.homeModules.direnv
        self.homeModules.editor
        self.homeModules.git
        self.homeModules.misc-utils
        self.homeModules.shell
        self.homeModules.ssh-client
        self.homeModules.starship
        self.homeModules.tmux
        self.homeModules.upgrade-diff
        self.homeModules.darwin-hm
        self.homeModules.zellij
      ];
      programs.home-manager.enable = lib.mkForce true;
    };

  # NixOS bundle - always-on base NixOS modules
  flake.nixosModules.personal = {
    imports = [
      self.nixosModules.base
      self.nixosModules.upgrade-diff
      self.nixosModules.ssh-server
      self.nixosModules.tailscale
      self.nixosModules.user
      self.nixosModules.networkmanager
      self.nixosModules.stylix
    ];
  };

  # Darwin bundle - always-on base Darwin modules
  flake.darwinModules.personal = {
    imports = [
      inputs.stylix.darwinModules.stylix
      self.darwinModules.base
      self.darwinModules.user
      self.darwinModules.brew
      self.darwinModules.upgrade-diff
      self.darwinModules.rancher
      self.darwinModules.fonts
      self.darwinModules.dock
    ];
  };
}
