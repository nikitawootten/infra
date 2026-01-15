{ config, self, ... }:
{
  imports = [ self.darwinModules.personal ];

  home-manager.users.${config.system.primaryUser} = import ./nikita.nix;
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "persephone";
}
