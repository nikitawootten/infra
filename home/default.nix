{ nixpkgs, home-manager, personalLib, overlays, specialArgs, ... }:
personalLib.mkHomes {
  inherit nixpkgs home-manager overlays specialArgs;
  defaultModules = [
    ./common
  ];
  homes =
    let
      default = {
        username = "nikita";
        system = "x86_64-linux";
      };
    in
    {
      # Framework laptop running NixOS
      "nikita@voyager" = default // {
        modules = [
          ./optional/firefox.nix
          ./optional/vscode.nix
          ./optional/gnome.nix
          ./optional/sectools.nix
          ./optional/fonts.nix
          ./optional/firefox-gnome-theme.nix
          ./optional/firefox-sideberry-autohide.nix
          {
            firefoxConfig.sideberry-autohide = {
              enable = true;
              profiles = [ "default" ];
            };
          }
        ];
      };
      # Desktop running Fedora (single user Nix install due to SELinux)
      "nikita@defiant" = default;
      # Dell Poweredge R610 running NixOS
      # TODO configure SSH-Agent forwarding
      "nikita@danzek" = default;
      # Work machine running MacOS
      "naw2@PN118973" = {
        username = "naw2";
        system = "aarch64-darwin";
        modules = [
          ./optional/fonts.nix
          ./optional/work.nix
          ({ lib, ... }: {
            programs.git.extraConfig.user.signingKey = lib.mkForce
              "key::ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM5wxg2WEXR5Tb1+BtXJmKG1hqMKjzYcHQgB3jxZjiQhTS9qZugjFLjqtrOP4XySHYDVLTzFwlsTR4Bw+lveGz0= naw2@PN118973";
          })
        ];
      };
    };
}
