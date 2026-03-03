{ ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    {
      # PrismLauncher installed via brew cask on MacOS
      home.packages = with pkgs; [ ] ++ lib.lists.optionals pkgs.stdenv.isLinux [ prismlauncher ];
    };
in
{
  flake.modules.homeManager.role-play = hmModule;

  flake.modules.nixos.role-play =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ hmModule ];

      nixpkgs.config.allowUnfree = true;
      programs.steam.enable = true;

      # Thunder store client
      environment.systemPackages = with pkgs; [ r2modman ];
    };

  flake.modules.darwin.role-play =
    { ... }:
    {
      home-manager.sharedModules = [ hmModule ];

      homebrew.casks = [
        "steam"
        "prismLauncher"
        "kicad"
        "freecad"
        "calibre"
      ];
    };
}
