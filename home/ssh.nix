{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
      };
    };
    # Escape hatch allow additional configs in ~/.ssh/confid.d/
    includes = [ "config.d/*" ];
  };
}
