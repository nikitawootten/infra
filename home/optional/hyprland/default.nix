{ pkgs, ... }@inputs:
let
  hyprlandInputs = inputs // {
    mods = {
      focus = "SUPER";
      window = "SUPERSHIFT";
      monitor = "SUPERCONTROLSHIFT";
    };
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig =
      (import ./binds.nix hyprlandInputs) +
      (import ./io.nix hyprlandInputs) +
      (import ./nav.nix hyprlandInputs);
  };
}