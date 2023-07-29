{ username, hyprland, ... }:
{
  imports = [
    hyprland.nixosModules.default
  ];
  programs.hyprland.enable = true;
  
  # for backlight control
  users.users.${username}.extraGroups = [ "video" ];
}