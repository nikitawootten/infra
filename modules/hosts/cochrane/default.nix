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
  flake.nixosConfigurations.cochrane = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      (
        {
          pkgs,
          config,
          ...
        }:
        {
          imports = [
            ./_hardware-configuration.nix
            self.nixosModules.personal
            self.nixosModules.niri
            self.nixosModules.bluetooth
            self.nixosModules.role-play
            self.nixosModules.role-security
            self.nixosModules.role-work
            self.nixosModules.zsa
            inputs.lanzaboote.nixosModules.lanzaboote
          ];

          # Bootloader
          environment.systemPackages = with pkgs; [ sbctl ];

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };

          boot.loader.systemd-boot.enable = false;
          boot.loader.efi.canTouchEfiVariables = true;

          boot.initrd.systemd.enable = true;
          boot.initrd.luks.devices."luks-f190f8c5-0961-45c4-a785-d7f3692e65f8".device =
            "/dev/disk/by-uuid/f190f8c5-0961-45c4-a785-d7f3692e65f8";

          boot.supportedFilesystems = [ "ntfs" ];

          # Rotate the screen
          # (GPD pocket 2 uses a tablet screen, so the default orientation is sideways)
          boot.kernelParams = [
            "fbcon=rotate:1"
            "video=eDP-1:panel_orientation=right_side_up"
          ];
          # Set a usable console font size
          console = {
            # ls /etc/kbd/consolefonts
            font = "ter-132n";
            packages = with pkgs; [ terminus_font ];
            earlySetup = true;
          };

          fonts.fontconfig.subpixel.rgba = "vbgr";

          networking.hostName = "cochrane";

          personal.niri.extraSettings = {
            outputs.eDP-1 = {
              scale = 1.5;
            };
            layout.gaps = 8;
            layout.border.width = 2;
          };
          programs.nix-ld.enable = true;

          home-manager.users.${config.personal.user.name} = {
            imports = [ self.homeModules.bridge ];
            home.packages = with pkgs; [
              tor-browser
              zed-editor
            ];
            programs.git.settings.credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
          };
        }
      )
    ];
    inherit specialArgs;
  };
}
