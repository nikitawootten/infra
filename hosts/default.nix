{ nixpkgs, personalLib, overlays, homeConfigs, specialArgs, ... }:
personalLib.mkHosts {
  inherit nixpkgs overlays homeConfigs specialArgs;
  configBasePath = ./.;
  defaultModules = [
    ./common/base.nix
    ./common/sudo.nix
    ./common/ssh-server.nix
  ];
  hosts = {
    danzek = {
      username = "nikita";
      system = "x86_64-linux";
      modules = [
        ./common/zfs.nix
        ./common/tailscale.nix
      ];
    };
  };
}
