{ lib, self, inputs, pkgs, ... }: {
  imports = [
    inputs.stylix.darwinModules.stylix
    inputs.home-manager.darwinModules.home-manager
    ./roles
    ./brew.nix
    ./dock.nix
    ./fonts.nix
    ./rancher.nix
    ./system.nix
    ./upgrade-diff.nix
    ./user.nix
  ];

  personal.fonts.enable = lib.mkDefault true;
  personal.brew.enable = lib.mkDefault true;
  personal.upgrade-diff.enable = lib.mkDefault true;
  personal.rancher.enable = lib.mkDefault true;

  programs.zsh.enable = true;

  nix = {
    optimise.automatic = true;
    settings = {
      trusted-users = [ "@admin" ];
      experimental-features = "nix-command flakes";
    };
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Needed to build remote nixos systems
  environment.systemPackages = with pkgs; [ nixos-rebuild ];
}
