{ nixpkgs, personalLib, overlays, homeConfigs, specialArgs, ... }:
personalLib.mkHosts {
  inherit nixpkgs overlays homeConfigs specialArgs;
  configBasePath = ./.;
  defaultModules = [
    ./common
  ];
  hosts = {
    hades = {
      username = "nikita";
      system = "x86_64-linux";
      modules = [
        ./optional/zfs.nix
        ./optional/docker.nix
      ];
    };
    voyager = {
      username = "nikita";
      system = "x86_64-linux";
      modules = [
        specialArgs.nixos-hardware.nixosModules.framework
        ./optional/sound.nix
        ./optional/networkmanager.nix
        ./optional/printing.nix
        ./optional/gnome.nix
        ./optional/steam.nix
        ./optional/docker.nix
        ./optional/vpn.nix
        ./optional/wireshark.nix
        {
          flatpak.enable = true;
        }
      ];
    };
  };
}
