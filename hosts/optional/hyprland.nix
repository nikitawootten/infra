{ username, hyprland, ... }:
{
  programs.hyprland.enable = true;
  
  # for backlight control
  users.users.${username}.extraGroups = [ "video" ];
  services.dbus.enable = true;
  xdg.portal.enable = true;
}