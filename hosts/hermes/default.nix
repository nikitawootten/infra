# Bootstrapped via the following command:
# $ nix run github:nix-community/nixos-anywhere -- --flake .#hermes <user@host> --build-on-remote
{ self, inputs, config, ... }: {
  imports = [
    self.nixosModules.personal
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disk-config.nix
    ./public.nix
  ];
  networking.hostName = "hermes";

  services.tailscale.useRoutingFeatures = "server";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  topology.self = {
    hardware.info = "Oracle Cloud VM";
    interfaces = {
      enp0s6 = {
        physicalConnections =
          [ (config.lib.topology.mkConnection "internet" "*") ];
      };
    };
  };
}
