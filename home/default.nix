{ nixpkgs, home-manager, personalLib, overlays, specialArgs, ... }:
personalLib.mkHomes {
  inherit nixpkgs home-manager overlays specialArgs;
  defaultModules = (import ./common);# ++ [specialArgs.nix-index-database.hmModules.nix-index];
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
          ./optional/fonts.nix
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
        modules = [{
          programs.git.userEmail = nixpkgs.lib.mkForce "nikita.wootten@nist.gov";
          programs.git.extraConfig.user.signingKey = nixpkgs.lib.mkForce
            "key::ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM5wxg2WEXR5Tb1+BtXJmKG1hqMKjzYcHQgB3jxZjiQhTS9qZugjFLjqtrOP4XySHYDVLTzFwlsTR4Bw+lveGz0= naw2@PN118973";
          # output of `eval "$(/opt/homebrew/bin/brew shellenv)"`
          home.sessionVariables = {
            HOMEBREW_PREFIX = "/opt/homebrew";
            HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
            HOMEBREW_REPOSITORY = "/opt/homebrew";
            MANPATH = "/opt/homebrew/share/man\${MANPATH+:$MANPATH}:";
            INFOPATH = "/opt/homebrew/share/info:\${INFOPATH:-}";
          };
          home.sessionPath = [
            "/opt/homebrew/bin"
            "/opt/homebrew/sbin"
          ];
        }];
      };
    };
}
