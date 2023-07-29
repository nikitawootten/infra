{ nixpkgs
, home-manager
, homes
, defaultModules ? [ ]
, overlays ? [ ]
, specialArgs ? { }
}:
let
  commonModules = username: system: [
    {
      home = {
        inherit username;
        homeDirectory = nixpkgs.lib.mkDefault "${if (nixpkgs.lib.hasInfix "darwin" system) then "/Users" else "/home"}/${username}";
        stateVersion = nixpkgs.lib.mkDefault "22.11";
      };
      programs.home-manager.enable = nixpkgs.lib.mkDefault true;
      nix = {
        # NixOS overrides this
        package = nixpkgs.lib.mkDefault nixpkgs.legacyPackages.${system}.nixFlakes;
        extraOptions = nixpkgs.lib.mkDefault ''
          experimental-features = nix-command flakes
        '';
      };
    }
  ] ++ defaultModules;

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = _: { username, system, modules ? [ ] }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system overlays; };
      extraSpecialArgs = {
        inherit system;
      } // specialArgs;
      modules = modules ++ (commonModules username system);
    };

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModule = _: { username, system, modules ? [ ] }:
    [ home-manager.nixosModules.home-manager ] ++ map
      (module:
        let
          commonInherits = {
            pkgs = import nixpkgs { inherit system overlays; };
            lib = nixpkgs.lib;
            inherit system;
          } // specialArgs;
        in
        {
          # Resolve import if path type is passed in
          home-manager.users.${username} = if builtins.isPath module then (import module commonInherits) else module;
        })
      (modules ++ (commonModules username system));
in
{
  homeConfigurations = builtins.mapAttrs mkHomeManagerConfig homes;
  nixosHomeModules = builtins.mapAttrs mkHomeManagerNixOsModule homes;
}
