{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # deprecation
    matchBlocks = {
      "github.com" = {
        user = "git";
        identitiesOnly = true;
        # Connect over HTTPS port (useful in restricted wifi environments like conferences)
        hostname = "ssh.github.com";
        port = 443;
      };
      "codeberg.org" = {
        user = "git";
        identitiesOnly = true;
      };
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
          IgnoreUnknown = "AddKeysToAgent,UseKeychain";
        };
      };
    };
    # Escape hatch allow additional configs in ~/.ssh/config.d/
    includes = [ "config.d/*" ];
  };
}
