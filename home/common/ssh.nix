{ lib, pkgs, system, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
      };
    } // lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
      # On darwin systems, force SSH to use the MacOS keychain
      "*" = {
        extraOptions = {
          UseKeychain = "yes";
          AddKeysToAgent = "yes";
        };
      };
    };
    # Escape hatch allow additional configs in ~/.ssh/confid.d/
    includes = [ "config.d/*" ];
  };
}
