{ self, config, lib, secrets, ... }: {
  imports = [
    self.nixosModules.raspi4sd
    self.nixosModules.personal
    self.nixosModules.homelab
    self.nixosModules.omada-controller
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

  services.omada-controller.enable = true;
  services.nginx.virtualHosts."omada-controller.${config.homelab.domain}" = {
    forceSSL = true;
    useACMEHost = config.homelab.domain;
    locations."/" = {
      proxyPass = "https://127.0.0.1:${
          toString config.services.omada-controller.portManageHTTPS
        }";
      recommendedProxySettings = true;
    };
  };

  networking.hostName = "iris";
}
