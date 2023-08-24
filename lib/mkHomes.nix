{ nixpkgs, home-manager, ... }:
{ homes
, configBasePath
, defaultModules ? [ ]
, specialArgs ? { }
, stateVersion ? "23.05"
}:
let
  parseEntry = entry:
    let
      entryItems = builtins.split "@" entry;
      username = builtins.elemAt entryItems 0;
      hostname = if builtins.length entryItems == 3
        then builtins.elemAt entryItems 2
        else null;
    in
    { inherit username hostname; };
  mkHomeManagerCommon = imports: hostname:
    ({ lib, username, system, ... }: 
    let
      homeFolderPath = (if builtins.isNull hostname
        then "${configBasePath}/${username}"
        else "${configBasePath}/${username}@${hostname}");
      homeFilePath = "${homeFolderPath}.nix";
      homeImports = (lib.lists.optional (builtins.pathExists homeFolderPath) homeFolderPath) ++
        (lib.lists.optional (builtins.pathExists homeFilePath) homeFilePath);
    in
    {
      imports = defaultModules ++ imports ++ [
        ({ pkgs, ... }: {
          nix = {
            package = lib.mkDefault pkgs.nixFlakes;
            extraOptions = ''
              experimental-features = nix-command flakes
            '';
          };
        })
      ] ++ homeImports;
      home = {
        inherit username;
        homeDirectory = lib.mkDefault "${if (lib.hasInfix "darwin" system) then "/Users" else "/home"}/${username}";
        stateVersion = lib.mkDefault stateVersion;
      };
      programs.home-manager.enable = lib.mkForce true;
    });

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = entry: { system, modules ? [ ] }:
    let
      parsedEntry = parseEntry entry;
      username = parsedEntry.username;
      hostname = parsedEntry.hostname;
    in
    home-manager.lib.homeManagerConfiguration {
      # TODO: temporary workaround until config override works?
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs // { inherit system username; };
      modules = [ (mkHomeManagerCommon modules hostname) ];
    };

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModules = entry: { system, modules ? [ ] }:
    let
      parsedEntry = parseEntry entry;
      username = parsedEntry.username;
      hostname = parsedEntry.hostname;
    in
    [
      home-manager.nixosModules.home-manager
      {
        # home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = specialArgs // { inherit system username; };
        home-manager.users.${username} = (mkHomeManagerCommon modules hostname);
      }
    ];
in
{
  homeConfigurations = builtins.mapAttrs mkHomeManagerConfig homes;
  nixosHomeModules = builtins.mapAttrs mkHomeManagerNixOsModules homes;
}
