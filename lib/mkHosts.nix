{ nixpkgs
, hosts
, homeConfigs ? null
, configBasePath
, defaultModules ? [ ]
, overlays ? [ ]
, specialArgs ? { }
}:
let
  # Generate a NixOS system with some common modules
  # Expects hardware specific modules to be defined in ./${hostname}
  # Also expects an associated ${username}@${hostname} home configuration
  mkSystem = hostname: { username, system, modules ? [ ] }:
    let
      homeModules =
        if (homeConfigs != null) then
          homeConfigs."${username}@${hostname}"
        else [ ];
    in
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        # Imports can use hostname and username
        inherit username;
      } // specialArgs;

      modules = [
        # Enable overlays
        ({lib, ... }: {
          networking.hostName = lib.mkDefault hostname;
          nixpkgs.overlays = overlays;
          imports = [
            "${configBasePath}/${hostname}"
          ];
        })
      ] ++ defaultModules ++ modules ++ homeModules;
    };
in
builtins.mapAttrs mkSystem hosts
