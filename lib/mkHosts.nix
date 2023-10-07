{ nixpkgs, ... }:
{ hosts
, homeConfigs ? null
, configBasePath
, defaultModules ? [ ]
, specialArgs ? { }
}:
let
  # Generate a NixOS system with some common modules
  # Expects hardware specific modules to be defined in ./${hostname}
  # Also optionally expects an associated ${username}@${hostname} home configuration
  mkSystem = hostname: { username, system, modules ? [ ] }:
    let
      homeModules =
        if (homeConfigs != null && builtins.hasAttr "${username}@${hostname}" homeConfigs) then
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
        ({lib, ... }: {
          networking.hostName = lib.mkDefault hostname;
          users.users.${username}.isNormalUser = lib.mkDefault true;

          imports = [
            "${configBasePath}/${hostname}"
          ];
        })
      ] ++ defaultModules ++ modules ++ homeModules;
    };
in
builtins.mapAttrs mkSystem hosts
