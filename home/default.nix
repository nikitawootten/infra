{ nixpkgs, home-manager, isNixOsModule ? false, ... }@inputs:
let
  # Common modules shared by all configs
  commonModules = [
    ./editor.nix
    ./git.nix
    ./nix.nix
    ./shell.nix
  ];

  # Conditionally generates config compatible with HomeManager flake or as NixOS modules
  mkHome = username: system: extraModules:
    (if isNixOsModule then mkHomeManagerNixOsModule else mkHomeManagerConfig) username system ([
      {
        home =
          let
            homesDir = if (nixpkgs.lib.hasInfix "darwin" system) then "/Users" else "/home";
          in
          {
            inherit username;
            homeDirectory = "${homesDir}/${username}";
            stateVersion = "22.11";
          };
        programs.home-manager.enable = true;
      }
    ] ++ commonModules ++ extraModules);

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModule = username: _: modules: map
    (module: {
      # Resolve import if path type is passed in
      home-manager.users.${username} = if builtins.isPath module then (import module inputs) else module;
    })
    modules;

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = _: system: modules:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      inherit modules;
    };
in
{
  "nikita@yukon" = mkHome "nikita" "x86_64-linux" [
    ./git-signed.nix
  ];
  "nikita@danzek" = mkHome "nikita" "x86_64-linux" [ ];

  "naw2@PN118973" = mkHome "naw2" "aarch64-darwin" [{
    programs.git.userEmail = nixpkgs.lib.mkForce "nikita.wootten@nist.gov";
  }];
}
