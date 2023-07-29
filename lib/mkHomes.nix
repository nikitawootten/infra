{ nixpkgs
, home-manager
, homes
, defaultModules ? [ ]
, overlays ? [ ]
, specialArgs ? { }
, stateVersion ? "22.11"
}:
let
  mkHomeManagerCommon = imports:
    ({ username, system, ...}: {
      imports = defaultModules ++ imports;
      home = {
        inherit username;
        homeDirectory = nixpkgs.lib.mkDefault "${if (nixpkgs.lib.hasInfix "darwin" system) then "/Users" else "/home"}/${username}";
        stateVersion = nixpkgs.lib.mkDefault stateVersion;
      };
      programs.home-manager.enable = nixpkgs.lib.mkDefault true;
    });

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = _: { username, system, modules ? [ ] }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system overlays; };
      extraSpecialArgs = specialArgs // { inherit system username; };
      modules = [ (mkHomeManagerCommon modules) ];
    };

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModules = _: { username, system, modules ? [ ] }:
    [ 
      home-manager.nixosModules.home-manager
      {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs // { inherit system username; };
          home-manager.users.${username} = (mkHomeManagerCommon modules);
      }
    ];
in
{
  homeConfigurations = builtins.mapAttrs mkHomeManagerConfig homes;
  nixosHomeModules = builtins.mapAttrs mkHomeManagerNixOsModules homes;
}
