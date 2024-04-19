{ self, inputs, config, lib, secrets, ... }: {
  imports = [
    inputs.agenix.nixosModules.default

    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
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

  homelab.observability.enable = true;
  homelab.homepage.enable = true;

  age.secrets.cloudflare-dns.file = secrets.traefik;
  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;
}
