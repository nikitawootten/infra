{
  personal.vscode.enable = true;
  personal.gnome.enable = true;
  personal.gnome.enableGSConnect = true;
  personal.fonts.enable = true;
  personal.sectools.enable = true;
  personal.firefox.enable = true;
  # personal.firefox.gnome-theme.enable = true;
  # personal.firefox.sideberry-autohide = {
  #   enable = true;
  #   profiles = [ "default" ];
  # };

  programs.firefox.profiles.default.settings = {
    "gfx.webrender.all" = true; # Force enable GPU acceleration
    "media.ffmpeg.vaapi.enabled" = true;
    "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
  };
}
