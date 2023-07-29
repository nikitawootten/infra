{ nixpkgs
, home-manager
, homes
, defaultModules ? [ ]
, overlays ? [ ]
, specialArgs ? { }
, stateVersion ? "23.05"
}:
let
  mkHomeManagerCommon = imports:
    ({ lib, username, system, ... }: {
      imports = defaultModules ++ imports;
      home = {
        inherit username;
        homeDirectory = lib.mkDefault "${if (lib.hasInfix "darwin" system) then "/Users" else "/home"}/${username}";
        stateVersion = lib.mkDefault stateVersion;
      };
      programs.home-manager.enable = lib.mkDefault true;
      nixpkgs = { inherit overlays; };
    });

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = _: { username, system, modules ? [ ] }:
    home-manager.lib.homeManagerConfiguration {
      # TODO: temporary workaround until config override works?
      pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };
      # pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs // { inherit system username; };
      modules = [ (mkHomeManagerCommon modules) ];
    };

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModules = _: { username, system, modules ? [ ] }:
    [
      home-manager.nixosModules.home-manager
      {
        # home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = specialArgs // { inherit system username; };
        home-manager.users.${username} = (mkHomeManagerCommon modules);
      }
    ];
in
{
  homeConfigurations = builtins.mapAttrs mkHomeManagerConfig homes;
  nixosHomeModules = builtins.mapAttrs mkHomeManagerNixOsModules homes;
}
