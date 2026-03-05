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
  flake.darwinConfigurations.persephone = inputs.darwin.lib.darwinSystem {
    modules = [
      (
        { config, ... }:
        {
          imports = [
            self.darwinModules.personal
            self.darwinModules.role-work
          ];

          home-manager.users.${config.system.primaryUser} =
            { pkgs, keys, ... }:
            {
              personal.git.signingKey = keys.nikita_persephone;

              home.packages = with pkgs; [ swiftlint ];
            };

          nixpkgs.hostPlatform = "aarch64-darwin";

          networking.hostName = "persephone";
        }

      )
    ];
    inherit specialArgs;
  };
}
