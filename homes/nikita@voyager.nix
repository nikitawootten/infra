{ pkgs, ... }: {
  personal.vscode.enable = true;
  personal.gnome.enable = true;
  # personal.gnome.enablePaperWm = true;
  personal.gnome.enableGSConnect = true;
  personal.fonts.enable = true;
  personal.sectools.enable = true;
  personal.firefox.enable = true;
  # personal.firefox.gnome-theme.enable = true;
  # personal.firefox.sideberry-autohide = {
  #   enable = true;
  #   profiles = [ "default" ];
  # };

  personal.cluster-admin.enable = true;

  home.packages = with pkgs; [ tor-browser-bundle-bin ];
}
