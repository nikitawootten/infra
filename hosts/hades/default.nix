{ self, config, secrets, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    self.nixosModules.homelab
    ./minecraft.nix
  ];

  topology.self = {
    hardware.info = "Dell R720XD server";
    interfaces = { eno1 = { }; };
  };

  services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];

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

  age.secrets.kanidm-password.file = secrets."kanidm-password";
  age.secrets.kanidm-password.owner = "kanidm";
  age.secrets.oauth2-proxy-client-secret.file =
    secrets.oauth2-proxy-client-secret;
  age.secrets.oauth2-proxy-client-secret.owner = "kanidm";
  age.secrets.oauth2-proxy-config.file = secrets.oauth2-proxy-config;
  age.secrets.oauth2-proxy-config.owner = "oauth2-proxy";
  homelab.auth = {
    enable = true;
    kanidm.adminPasswordFile = config.age.secrets.kanidm-password.path;
    oauth2-proxy.clientSecretFile =
      config.age.secrets.oauth2-proxy-client-secret.path;
    oauth2-proxy.keyFile = config.age.secrets.oauth2-proxy-config.path;
  };

  # Media
  age.secrets."transmission".file = secrets."transmission";
  age.secrets.audiobookshelf-client-secret.file =
    secrets.audiobookshelf-client-secret;
  age.secrets.audiobookshelf-client-secret.owner = "kanidm";
  age.secrets.sonarr-basic-auth.file = secrets."sonarr-basic-auth";
  age.secrets.sonarr-basic-auth.owner = "nginx";
  age.secrets.radarr-basic-auth.file = secrets."radarr-basic-auth";
  age.secrets.radarr-basic-auth.owner = "nginx";
  age.secrets.prowlarr-basic-auth.file = secrets."prowlarr-basic-auth";
  age.secrets.prowlarr-basic-auth.owner = "nginx";
  homelab.media = {
    enable = true;
    mediaRoot = "/menagerie";
    configRoot = "/storage/config";
    transmission.transmissionEnvFile = config.age.secrets."transmission".path;
    ersatztv.image = "jasongdove/ersatztv:latest-nvidia";
    audiobookshelf.clientSecretFile =
      config.age.secrets.audiobookshelf-client-secret.path;
    sonarr.authHeaderFile = config.age.secrets."sonarr-basic-auth".path;
    radarr.authHeaderFile = config.age.secrets."radarr-basic-auth".path;
    prowlarr.authHeaderFile = config.age.secrets."prowlarr-basic-auth".path;
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
