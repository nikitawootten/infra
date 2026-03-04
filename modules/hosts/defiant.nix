{ self, inputs, ... }:
let
  secrets = import ./../../secrets;
  keys = import ./../../keys.nix;

  # Args passed to home-manager and nixos modules
  specialArgs = {
    inherit
      secrets
      keys
      ;
  };
in
{
  flake.darwinConfigurations.defiant = inputs.darwin.lib.darwinSystem {
    modules = [
      (
        { keys, ... }:
        {
          imports = [
            self.modules.darwin.personal
            self.modules.darwin.role-work
            self.modules.darwin.role-play
            self.modules.darwin.role-security
          ];

          nixpkgs.hostPlatform = "aarch64-darwin";

          # An unfortunate artifact from migrating from determinate nix to the official nix installer
          ids.gids.nixbld = 350;

          networking.computerName = "Nikita's MacBook Pro (Defiant)";
          networking.hostName = "defiant";

          home-manager.users.nikita = {
            personal.git.signingKey = keys.nikita_defiant;
          };
        }
      )
    ];
    inherit specialArgs;
  };
}
