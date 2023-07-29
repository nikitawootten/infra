{ self, nixpkgs, home-manager, overlays, ... }@inputs:
let
  homeConfigs = import ../home (inputs // { isNixOsModule = true; });

  # Common modules shared by all configs
  commonModules = [
    ./common/base.nix
    ./common/sudo.nix
    ./common/ssh-server.nix
  ];

  # Generate a NixOS system with some common modules
  # Expects hardware specific modules to be defined in ./${hostname}
  # Also expects an associated ${username}@${hostname} home configuration
  mkSystem = username: hostname: system: extraModules:
    nixpkgs.lib.nixosSystem {
      inherit system;

      # Imports can use hostname and username
      specialArgs = {
        inherit username hostname;
      };

      modules = [
        # Enable overlays
        {
          nixpkgs.overlays = overlays;
        }
        # Enable the use of home-manager modules
        home-manager.nixosModules.home-manager
        # Hardware-specific configuration
        ././${hostname}
      ] ++ commonModules ++ extraModules ++ homeConfigs."${username}@${hostname}";
    };
in
{
  danzek = mkSystem "nikita" "danzek" "x86_64-linux" [
    ./common/zfs.nix
  ];
}
