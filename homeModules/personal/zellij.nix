{ ... }: {
  programs.zellij.enable = true;

  # Zellij has moved to the KDL format for configuration
  # xdg.configFile."zellij/config.kdl".text = ''
  # '';
}
