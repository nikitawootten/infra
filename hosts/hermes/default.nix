# Bootstrapped via the following command:
# $ nix run github:nix-community/nixos-anywhere -- --flake .#hermes <user@host> --build-on-remote
{ self, inputs, ... }: {
  imports = [
    self.nixosModules.personal
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  networking.hostName = "hermes";

  services.tailscale.useRoutingFeatures = "server";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
