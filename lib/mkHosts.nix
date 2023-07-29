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
      hostConfigurationPath = "${configBasePath}/${hostname}";
      homeModules =
        if (homeConfigs != null) then
          homeConfigs."${username}@${hostname}"
        else [ ];
    in
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        # Imports can use hostname and username
        inherit username hostname;
      } // specialArgs;

      modules = [
        # Enable overlays
        {
          nixpkgs.overlays = overlays;
        }
        # Hardware-specific configuration
        hostConfigurationPath
      ] ++ defaultModules ++ modules ++ homeModules;
    };
in
builtins.mapAttrs mkSystem hosts
