{ self, keys, ... }:
{
  imports = [ self.darwinModules.personal ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # An unfortunate artifact from migrating from determinate nix to the official nix installer
  ids.gids.nixbld = 350;

  networking.computerName = "Nikita's MacBook Pro (Defiant)";
  networking.hostName = "defiant";

  home-manager.users.nikita = {
    personal.git.signingKey = keys.nikita_defiant;
  };
  personal.roles.work.enable = true;
  personal.roles.play.enable = true;
  personal.roles.security.enable = true;
}
