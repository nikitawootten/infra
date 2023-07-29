{ lib, pkgs, system, ... }:
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

  home.packages =
    if (lib.hasInfix "darwin" system) then with pkgs; [
      # packaged version doesn't support FIDO2
      openssh
    ] else [ ];
}
