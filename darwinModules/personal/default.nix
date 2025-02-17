{ lib, self, inputs, secrets, keys, ... }: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.stylix.darwinModules.stylix
    ./brew.nix
    ./fonts.nix
    ./system.nix
  ];

  personal.fonts.enable = lib.mkDefault true;
  personal.brew.enable = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit self inputs secrets keys; };
  home-manager.sharedModules = [{
    home.stateVersion = "24.11";
    imports = [ self.homeModules.personal ];
  }];

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true;

  nix.settings.trusted-users = [ "@admin" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
