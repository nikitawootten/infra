{ self, inputs, ... }:
{
  flake.darwinModules.base =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;

      nix = {
        optimise.automatic = true;
        settings = {
          trusted-users = [ "@admin" ];
          experimental-features = "nix-command flakes";
        };
        package = pkgs.nixVersions.stable;
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      };

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = 4;
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Needed to build remote nixos systems
      environment.systemPackages = with pkgs; [ nixos-rebuild ];

      # System preferences
      system = {
        defaults = {
          menuExtraClock.Show24Hour = true;

          finder = {
            _FXShowPosixPathInTitle = true; # show full path in finder title
            AppleShowAllExtensions = true; # show all file extensions
            FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
            QuitMenuItem = true; # enable quit menu item
            ShowPathbar = true; # show path bar
            ShowStatusBar = true; # show status bar
            NewWindowTarget = "Home";
          };

          NSGlobalDomain = {
            # Full keyboard navigation
            AppleKeyboardUIMode = 3;
          };

          CustomUserPreferences = {
            NSGlobalDomain = {
              # Add a context menu item for showing the Web Inspector in web views
              WebKitDeveloperExtras = true;
            };

            "com.apple.desktopservices" = {
              # Avoid creating .DS_Store files on network or USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };

            "com.apple.AdLib" = {
              allowApplePersonalizedAdvertising = false;
            };
          };
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };
      };

      # Add ability to used TouchID for sudo authentication
      security.pam.services.sudo_local.touchIdAuth = true;
    };
}
