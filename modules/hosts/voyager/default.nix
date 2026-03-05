{ self, inputs, ... }:
let
  secrets = import ./../../../secrets;
  keys = import ./../../../keys.nix;
  specialArgs = {
    inherit
      secrets
      keys
      ;
  };
in
{
  flake.nixosConfigurations.voyager = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      (
        {
          lib,
          pkgs,
          config,
          ...
        }:
        {
          imports = [
            ./_hardware-configuration.nix
            inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
            inputs.lanzaboote.nixosModules.lanzaboote
            self.nixosModules.personal
            self.nixosModules.niri
            self.nixosModules.role-play
            self.nixosModules.role-security
            self.nixosModules.flatpak
            self.nixosModules.zsa
            self.nixosModules.virtualbox
          ];

          powerManagement.enable = true;

          systemd.sleep.extraConfig = "HibernateDelaySec=2h";

          services.udev.packages = [ pkgs.yubikey-personalization ];

          home-manager.sharedModules = [
            {
              programs.niri.settings = {
                outputs."eDP-1" = {
                  scale = 1.5;
                  variable-refresh-rate = true;
                };
              };
            }
          ];

          stylix.enable = true;
          stylix.image = pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/x6/wallhaven-x6pl9v.jpg";
            sha256 = "sha256-IXYn+ohEiv3IXfw+dta9TzNpZFto026h64hMDrTrDm8=";
          };
          stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/equilibrium-gray-dark.yaml";
          stylix.polarity = "dark";

          services.fprintd.enable = lib.mkForce false;

          home-manager.users.${config.personal.user.name} = {
            home.packages = with pkgs; [ tor-browser ];

            dconf.settings."org/gnome/mutter" = {
              experimental-features = [
                "scale-monitor-framebuffer"
                "xwayland-native-scaling"
              ];
            };
          };

          programs.nix-ld.enable = true;

          networking.hostName = "voyager";

          # Bootloader.
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.efi.efiSysMountPoint = "/boot/efi";
          boot.lanzaboote.enable = true;
          boot.lanzaboote.pkiBundle = "/etc/secureboot";

          environment.systemPackages = with pkgs; [
            sbctl
            android-studio
          ];

          # Needed to build aarch64 packages such as raspberry pi images
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

          boot.supportedFilesystems = [ "ntfs" ];

          # Setup keyfile
          boot.initrd.systemd.enable = true;
          boot.initrd.secrets = {
            "/crypto_keyfile.bin" = null;
          };

          # Enable swap on luks
          boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".device =
            "/dev/disk/by-uuid/4a0aabeb-46fd-48b4-b11e-96ba338f25e7";
          boot.initrd.luks.devices."luks-4a0aabeb-46fd-48b4-b11e-96ba338f25e7".keyFile =
            "/crypto_keyfile.bin";
        }
      )
    ];
    inherit specialArgs;
  };
}
