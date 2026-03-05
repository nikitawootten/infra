{ self, ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    {
      imports = [ self.homeModules.ghostty ];

      programs.gnome-shell = {
        enable = true;
        extensions = with pkgs; [
          { package = gnomeExtensions.alphabetical-app-grid; }
          { package = gnomeExtensions.appindicator; }
          { package = gnomeExtensions.tailscale-status; }
          { package = gnomeExtensions.pip-on-top; }
          { package = gnomeExtensions.caffeine; }
          { package = gnomeExtensions.system-monitor; }
          { package = gnomeExtensions.gsconnect; }
          { package = gnomeExtensions.clipboard-indicator; }
        ];
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/calendar" = {
            show-weekdate = true;
          };
          "org/gnome/desktop/interface" = {
            clock-format = "12h";
          };
          "org/gnome/system/location" = {
            enabled = true;
          };
          "org/gnome/desktop/datetime" = {
            automatic-timezone = true;
          };
          "org/gnome/desktop/wm/keybindings" = {
            switch-to-workspace-left = [ "<Control><Super>Left" ];
            switch-to-workspace-right = [ "<Control><Super>Right" ];
          };
          "org/gnome/desktop/input-sources" = {
            sources = [
              (lib.hm.gvariant.mkTuple [
                "xkb"
                "us"
              ])
              (lib.hm.gvariant.mkTuple [
                "xkb"
                "ru"
              ])
            ];
            xkb-options = [ "caps:escape_shifted_capslock" ];
          };
          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            natural-scroll = true;
          };
          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = true;
          };
          "org/gtk/gtk4/settings/file-chooser" = {
            show-hidden = true;
          };
          "org/gnome/nautilus/list-view" = {
            use-tree-view = true;
          };
          "org/gnome/mutter" = {
            edge-tiling = true;
            dynamic-workspaces = true;
          };
          "org/gnome/desktop/interface" = {
            gtk-enable-primary-paste = false;
          };
        };
      };

      programs.git = {
        package = pkgs.gitFull;
        extraConfig.credential.helper = "libsecret";
      };
    };
in
{
  flake.homeModules.gnome = hmModule;

  flake.nixosModules.gnome =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.sound ];

      home-manager.sharedModules = [ hmModule ];

      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      programs.dconf.enable = true;

      environment.gnome.excludePackages = with pkgs; [
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ];

      environment.systemPackages = with pkgs; [ gnome-tweaks ];

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # AC-8 copy-pasta
      services.displayManager.gdm.banner = ''
        You are accessing a private information system, which includes:
        1) this computer,
        2) this computer network,
        3) all computers connected to this network, and
        4) all devices and storage media attached to this network or to a computer on this network.
        You understand and consent to the following:
        - you may access this information system for authorized use only;
        - you have no reasonable expectation of privacy regarding any communication of data transiting or stored on this information system;
        - at any time and for any lawful purpose, we may monitor, intercept, and search and seize any communication or data transiting or stored on this information system;
        - and any communications or data transiting or stored on this information system may be disclosed or used for any lawful purpose.
      '';
    };
}
