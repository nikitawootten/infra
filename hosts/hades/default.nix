{ self, config, secrets, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
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
  hardware.nvidia.open = false;

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
    mediaRoot = "/menagerie";
    configRoot = "/storage/config";
    transmission.transmissionEnvFile = config.age.secrets."transmission".path;
    ersatztv.image = "jasongdove/ersatztv:latest-nvidia";
  };
  users.groups.media.gid = 993;

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

  environment.systemPackages = with pkgs; [ mergerfs ];
  fileSystems."/menagerie" = {
    fsType = "fuse.mergerfs";
    device = "/storage*/media";
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs"
      "minfreespace=100G"
      "fsname=menageriePool"
      # "x-systemd.requires=/storage/media"
      # "x-systemd.requires=/storage2/media"
      "x-systemd.requires=zfs-mount.service"
    ];
  };
}
