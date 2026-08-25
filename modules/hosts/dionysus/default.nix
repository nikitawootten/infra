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
  flake.nixosConfigurations.dionysus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      (
        { config, ... }:
        {
          imports = [
            ./_hardware-configuration.nix
            self.nixosModules.personal
            self.nixosModules.dslr-webcam
            self.nixosModules.niri
            self.nixosModules.bluetooth
            self.nixosModules.role-play
            self.nixosModules.role-security
            self.nixosModules.role-work
            self.nixosModules.virtualbox
            self.nixosModules.nvidia
            self.nixosModules.zsa
            inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          ];

          personal.nvidia = {
            headless = false;
            suspend = true;
            betaDriver = true;
          };

          dslr-webcam = {
            enable = true;
            camera-udev-product = "7b4/130/100"; # My beloved Olympus OM-D EM5 Mark II
            ffmpeg-hwaccel = true;
          };

          services.hardware.openrgb = {
            enable = true;
            motherboard = "amd";
          };

          networking.hostName = "dionysus";

          personal.niri.extraSettings._children = [
            {
              output = {
                _args = [ "HDMI-A-1" ];
                position._props = {
                  x = 0;
                  y = 0;
                };
                mode = "3440x1440@100.000";
              };
            }
          ];

          home-manager.users.${config.personal.user.name} = {
            imports = [ self.homeModules.zed ];

            personal.git.signingKey = keys.nikita_dionysus;

            programs.firefox.profiles.default.settings = {
              "gfx.webrender.all" = true; # Force enable GPU acceleration
              "media.hardware-video-decoding.force-enabled" = true;
              "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
            };

            programs.zed-editor.installRemoteServer = true;
          };

          programs.nix-ld.enable = true;

          personal.niri.idleAction = "suspend";

          boot.kernelParams = [ "video=DP-1:panel_orientation=right_side_up" ];

          # Needed to build aarch64 packages such as raspberry pi images
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
        }
      )
    ];
    inherit specialArgs;
  };
}
