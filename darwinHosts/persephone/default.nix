{ pkgs, self, inputs, keys, ... }: {
  imports = [ self.darwinModules.personal ];

  home-manager.users.nikita = import ./nikita.nix;
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.nikita = {
    name = "nikita";
    home = "/Users/nikita";
  };

  homebrew.casks = [ "xcodes" ];

  networking.hostName = "persephone";
}
