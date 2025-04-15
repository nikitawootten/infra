{ lib, self, inputs, secrets, keys, pkgs, ... }: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./roles
    ./brew.nix
    ./dock.nix
    ./fonts.nix
    ./rancher.nix
    ./system.nix
    ./upgrade-diff.nix
  ];

  personal.fonts.enable = lib.mkDefault true;
  personal.brew.enable = lib.mkDefault true;
  personal.upgrade-diff.enable = lib.mkDefault true;
  personal.rancher.enable = lib.mkDefault true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit self inputs secrets keys; };
  home-manager.sharedModules = [{
    home.stateVersion = "24.11";
    imports = [ self.homeModules.personal ];
  }];

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
