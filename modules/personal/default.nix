{ self, inputs, ... }:
{
  flake.modules.homeManager.personal =
    { lib, ... }:
    {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
        self.modules.homeManager.direnv
        self.modules.homeManager.editor
        self.modules.homeManager.git
        self.modules.homeManager.misc-utils
        self.modules.homeManager.shell
        self.modules.homeManager.ssh-client
        self.modules.homeManager.starship
        self.modules.homeManager.tmux
        self.modules.homeManager.upgrade-diff
        self.modules.homeManager.darwin-hm
        self.modules.homeManager.zellij
      ];
      programs.home-manager.enable = lib.mkForce true;
    };

  # NixOS bundle - always-on base NixOS modules
  flake.modules.nixos.personal = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.upgrade-diff
      self.modules.nixos.ssh-server
      self.modules.nixos.tailscale
      self.modules.nixos.user
      self.modules.nixos.networkmanager
      self.modules.nixos.stylix
    ];
  };

  # Darwin bundle - always-on base Darwin modules
  flake.modules.darwin.personal = {
    imports = [
      inputs.stylix.darwinModules.stylix
      self.modules.darwin.base
      self.modules.darwin.user
      self.modules.darwin.brew
      self.modules.darwin.upgrade-diff
      self.modules.darwin.rancher
      self.modules.darwin.fonts
      self.modules.darwin.dock
    ];
  };
}
