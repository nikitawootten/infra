{ ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          monospace-font-name = lib.mkDefault "JetBrains Mono 10";
        };
      };
    };
in
{
  flake.homeModules.fonts = hmModule;

  flake.darwinModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          jetbrains-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          nerd-fonts.jetbrains-mono
        ];
      };
    };
}
