{ self, lib, ... }:
{
  imports = [
    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
  ];

  sdImage.compressImage = lib.mkForce true;

  homelab.observability.grafana.enable = true;
}
