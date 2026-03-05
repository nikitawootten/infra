{ self, inputs, ... }:
let
  secrets = import ./../../secrets;
  keys = import ./../../keys.nix;
  specialArgs = {
    inherit
      secrets
      keys
      ;
  };
in
{
  flake.nixosConfigurations.iris = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      (
        {
          config,
          lib,
          ...
        }:
        {
          imports = [
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

          age.secrets.cloudflare-dns.file = secrets.traefik;
          homelab.acme.email = "me@nikita.computer";
          homelab.acme.dnsProvider = "cloudflare";
          homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;

          networking.hostName = "iris";
        }
      )
    ];
    inherit specialArgs;
  };
}
