{ ... }: {
  programs.zellij = {
    enable = true;
    # Disable auto-start on shell creation
    enableZshIntegration = false;
    enableBashIntegration = false;
    enableFishIntegration = false;
  };
}
