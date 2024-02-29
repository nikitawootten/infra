{ self, config, lib, secrets, agenix, ... }:
{
  imports = [
    agenix.nixosModules.default

    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
  ];

  sdImage.compressImage = lib.mkForce true;

  homelab.lan-domain = "arpa.nikita.computer";

  homelab.observability.grafana.enable = true;
  homelab.observability.prometheus.enable = true;
  homelab.observability.loki.enable = true;

  age.secrets.cloudflare-dns.file = secrets.traefik;

  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;
}
