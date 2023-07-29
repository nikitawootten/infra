{ lib, pkgs, system, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
        # Connect over HTTPS port (useful in restricted wifi environments like conferences)
        hostname = "ssh.github.com";
        port = 443;
      };
    } // lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
      # On darwin systems, force SSH to use the MacOS keychain
      "*" = {
        extraOptions = {
          # Mitigating https://github.com/NixOS/nixpkgs/issues/15686 for now
          IgnoreUnknown = "AddKeysToAgent,UseKeychain";
          UseKeychain = "yes";
          AddKeysToAgent = "yes";
        };
      };
    };
    # Escape hatch allow additional configs in ~/.ssh/confid.d/
    includes = [ "config.d/*" ];
  };
}
