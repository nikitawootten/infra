{ ... }: {
  system = {
    defaults = {
      menuExtraClock.Show24Hour = true;

      finder = {
        _FXShowPosixPathInTitle = true; # show full path in finder title
        AppleShowAllExtensions = true; # show all file extensions
        FXEnableExtensionChangeWarning =
          false; # disable warning when changing file extension
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

        "com.apple.AdLib" = { allowApplePersonalizedAdvertising = false; };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
