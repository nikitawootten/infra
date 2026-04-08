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
        {
          config,
          pkgs,
          ...
        }:
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
            inputs.nix-topology.nixosModules.default
          ];

          topology.self = {
            hardware.info = "AMD Threadripper 2920X + NVIDIA 2080TI desktop";
            interfaces = {
              enp8s0 = { };
              wlp5s0 = {
                physicalConnections = [ (config.lib.topology.mkConnection "ap1" "wlan0") ];
              };
            };
          };

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

          personal.niri.extraSettings = {
            outputs.DP-1 = {
              transform = "270";
              position = _: {
                props = {
                  x = 3440;
                  y = -560;
                };
              };
              mode = "2560x1440@74.971";
              layout = {
                # Workable solution for vertical monitors until https://github.com/niri-wm/niri/issues/1071 is implemented
                default-column-width.proportion = 1.0;
              };
            };
            outputs.HDMI-A-1 = {
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
              mode = "3440x1440@100.000";
            };
          };

          home-manager.users.${config.personal.user.name} = {
            programs.firefox.profiles.default.settings = {
              "gfx.webrender.all" = true; # Force enable GPU acceleration
              "media.ffmpeg.vaapi.enabled" = true;
              "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
            };

            home.packages = with pkgs; [ zed-editor ];
          };

          programs.nix-ld.enable = true;

          # Disable auto-suspend
          services.displayManager.gdm.autoSuspend = false;

          # Multi-monitor support: Secondary monitor is rotated
          boot.kernelParams = [ "video=HDMI-1:panel_orientation=left_side_up" ];

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
