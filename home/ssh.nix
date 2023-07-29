{ lib, pkgs, system, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
      };
    } // (if (lib.hasInfix "darwin" system) then {
      # On darwin systems, force SSH to use the MacOS keychain
      "*" = {
        extraOptions = {
          UseKeychain = "yes";
          AddKeysToAgent = "yes";
        };
      };
    } else { });
    # Escape hatch allow additional configs in ~/.ssh/confid.d/
    includes = [ "config.d/*" ];
  };
}
