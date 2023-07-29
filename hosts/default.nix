{ nixpkgs, personalLib, overlays, homeConfigs, specialArgs, ... }:
personalLib.mkHosts {
  inherit nixpkgs overlays homeConfigs specialArgs;
  configBasePath = ./.;
  defaultModules = import ./common;
  hosts = {
    danzek = {
      username = "nikita";
      system = "x86_64-linux";
      modules = [
        ./optional/zfs.nix
      ];
    };
    voyager = {
      username = "nikita";
      system = "x86_64-linux";
      modules = [
        specialArgs.nixos-hardware.nixosModules.framework
        ./optional/sound.nix
        ./optional/networkmanager.nix
        ./optional/flatpak.nix
        ./optional/printing.nix
        ./optional/hyprland.nix
        specialArgs.hyprland.nixosModules.default
      ];
    };
  };
}
