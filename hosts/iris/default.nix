{ self, inputs, config, lib, secrets, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default

    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
  ];

  sdImage.compressImage = lib.mkForce true;

  homelab.lan-domain = "arpa.nikita.computer";

  homelab.observability.enable = true;
  homelab.homepage.enable = true;
  services.homepage-dashboard.services = [
    {
      observability = [
        {
          Grafna = {
            icon = "grafana.png";
            href = config.homelab.observability.grafana.url;
            description = "system monitoring";
          };
        }
      ];
    }
  ];

  age.secrets.cloudflare-dns.file = secrets.traefik;

  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;
}
