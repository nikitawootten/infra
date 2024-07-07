{ self, inputs, config, secrets, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.agenix.nixosModules.default
    inputs.nix-topology.nixosModules.default

    self.nixosModules.personal
    self.nixosModules.homelab
  ];

  topology.self = {
    hardware.info = "Dell R720XD server";
    interfaces = { eno1 = { }; };
  };

  # This machine is sometimes used as a build server
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  personal.zfs.enable = true;
  personal.docker.enable = true;
  personal.nvidia.enable = true;

  homelab.lan-domain = "arpa.nikita.computer";

  age.secrets.cloudflare-dns.file = secrets.traefik;
  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;

  homelab.observability.enable = true;

  # Media
  age.secrets."transmission".file = secrets."transmission";
  homelab.media = {
    enable = true;
    storageRoot = "/storage2/media";
    transmission.transmissionEnvFile = config.age.secrets."transmission".path;
  };
  users.groups.media.gid = 993;

  # Auth
  age.secrets.keycloak-db-pw.file = secrets.keycloak-db-pw;
  homelab.auth = {
    enable = true;
    keycloak.databasePasswordFile = config.age.secrets.keycloak-db-pw.path;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub.mirroredBoots = [{
    devices = [ "/dev/disks/by-id/wwn-0x5000c5007e5f2beb-part3" ];
    path = "/boot-fallback";
  }];

  networking.hostName = "hades";
  networking.hostId = "45389833";
  boot.zfs.extraPools = [ "storage" "storage2" ];
}
