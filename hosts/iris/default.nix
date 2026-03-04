{
  self,
  config,
  lib,
  secrets,
  ...
}:
{
  imports = [
    self.modules.nixos.raspi4sd
    self.modules.nixos.personal
    self.modules.nixos.homelab
  ];

  topology.self = {
    hardware.info = "Raspberry Pi 4";
    interfaces = {
      end0 = { };
      wlan0 = { };
    };
  };

  sdImage.compressImage = lib.mkForce true;

  homelab.lan-domain = "arpa.nikita.computer";

  age.secrets.cloudflare-dns.file = secrets.traefik;
  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;

  networking.hostName = "iris";
}
