{ self, inputs, ... }:
{
  flake.nixosModules.niri-desktop =
    { pkgs, lib, ... }:
    let
      peck = inputs.peck.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      programs.yubikey-touch-detector.enable = true;

      services.gnome.sushi.enable = true;
      services.gvfs.enable = true;

      # Required by `peck`.
      services.gnome.at-spi2-core.enable = true;

      environment.systemPackages = [
        pkgs.file-roller
        pkgs.nautilus
        pkgs.papers
        pkgs.simple-scan
        pkgs.loupe
        pkgs.showtime
        pkgs.snapshot
        pkgs.pavucontrol
        pkgs.glib
        pkgs.wl-clipboard
        peck
      ];

      hardware.brillo.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;

      # https://github.com/Supreeeme/xwayland-satellite/issues/150#issuecomment-2847677630
      programs.steam.package = pkgs.steam.override {
        extraArgs = "-system-composer";
      };

      home-manager.sharedModules = [
        {
          imports = [
            self.homeModules.fonts
            self.homeModules.ghostty
          ];

          home.packages = [ pkgs.fastfetch ];

          services.ssh-agent.enable = true;

          services.udiskie.enable = true;

          home.file.".face".source = pkgs.fetchurl {
            url = "https://avatars.githubusercontent.com/u/8916363";
            sha256 = "sha256-8hO46RoG4rCrB+bkIBAx/AU16jyQ6T9s5kopO6KLFo0=";
          };

          systemd.user.services.peck = {
            Unit = {
              Description = "peck activation daemon";
              After = [
                "graphical-session.target"
                "at-spi-dbus-bus.service"
              ];
              Wants = [ "at-spi-dbus-bus.service" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${lib.getExe peck} daemon";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          dconf.settings = {
            "org/gnome/desktop/interface" = {
              icon-theme = "Adwaita";
              toolkit-accessibility = true;
            };
          };

          gtk = {
            enable = true;
            # Noctalia's GTK hook swaps this between adw-gtk3 and adw-gtk3-dark.
            theme = {
              package = pkgs.adw-gtk3;
              name = "adw-gtk3";
            };
            # GTK4 apps ignore Noctalia's colors if a theme is set here.
            gtk4.theme = null;
            iconTheme = {
              package = pkgs.adwaita-icon-theme;
              name = "Adwaita";
            };
          };
        }
      ];
    };
}
