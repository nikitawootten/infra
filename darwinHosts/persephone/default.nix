{ config, self, ... }:
{
  imports = [
    self.modules.darwin.personal
    self.modules.darwin.role-work
  ];

  home-manager.users.${config.system.primaryUser} = import ./nikita.nix;
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "persephone";
}
