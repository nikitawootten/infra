{ ... }:
{
  programs.firefox = {
    enable = true;
  };
  home.sessionVariables.BROWSER = "firefox";
}