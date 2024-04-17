{ self, inputs, config, lib, secrets, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.nix-topology.nixosModules.default

    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
  ];

  sdImage.compressImage = lib.mkForce true;

  homelab.lan-domain = "arpa.nikita.computer";

  homelab.observability.enable = true;
  homelab.homepage.enable = true;

  age.secrets.cloudflare-dns.file = secrets.traefik;
  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;
}
