{ self, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      baseSettings = {
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        layout.background-color = "transparent";
        layout.border.off = { };
        layout.focus-ring.width = 4;
        layout.tab-indicator = {
          position = "left";
          gap = 0;
          width = 4;
          length._props.total-proportion = 0.5;
        };
        layout.gaps = 8;
        input = {
          focus-follows-mouse._props.max-scroll-amount = "10%";
          keyboard = {
            xkb = {
              layout = "us,ru";
              options = "grp:win_space_toggle,caps:escape";
            };
          };
          mouse = {
            scroll-factor = 0.5;
          };
          touchpad = {
            natural-scroll = { };
            dwt = { };
            drag-lock = { };
            tap = { };
          };
          workspace-auto-back-and-forth = { };
        };
        clipboard.disable-primary = { };
        prefer-no-csd = { };
        # Allows notification actions and window activation from Noctalia
        debug.honor-xdg-activation-with-invalid-serial = { };
      };
    in
    {
      imports = [
        self.nixosModules.sound
        self.nixosModules.niri-noctalia
        self.nixosModules.niri-greeter
        self.nixosModules.niri-desktop
      ];

      options.personal.niri = {
        extraSettings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = ''
            Host-specific niri settings, merged with the defaults. Uses
            home-manager's KDL dialect: `_props` for node properties, `_args`
            for positional arguments and `_children` for repeated nodes such as
            `output`.
          '';
        };
        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "The niri package in use";
        };
      };

      config = {
        # Required for `peck`
        personal.niri.package = pkgs.niri.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "kiryl";
            repo = "niri";
            rev = "d26ab5f29df670110a91a7e933a743eeaf611978";
            hash = "sha256-3HxntJA2DNg+L94gbM86uGeJqPPWbSX88CjteOmYV0o=";
          };
        });

        programs.niri = {
          enable = true;
          package = config.personal.niri.package;
        };
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        home-manager.sharedModules = [
          {
            imports = [
              self.homeModules.niri-binds
              self.homeModules.niri-window-rules
            ];

            wayland.windowManager.niri = {
              enable = true;
              # Shared with the system-level `programs.niri`, which already
              # installs the session and its systemd units.
              package = config.personal.niri.package;
              systemd.enable = false;
              portalPackage = null;
              xwaylandSatellitePackage = null;
              settings = lib.mkMerge [
                baseSettings
                config.personal.niri.extraSettings
              ];
              extraConfig = ''
                include optional=true "~/.config/niri/noctalia.kdl"
              '';
            };
          }
        ];
      };
    };
}
