{ self, inputs, keys, ... }: {
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit self inputs keys; };

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  services.nix-daemon.enable = true;
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
