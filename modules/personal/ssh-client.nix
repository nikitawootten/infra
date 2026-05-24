{ ... }:
{
  flake.homeModules.ssh-client =
    { lib, pkgs, ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false; # we set our own "*" defaults below
        settings = {
          "github.com" = {
            User = "git";
            IdentitiesOnly = true;
            # Connect over HTTPS port (useful in restricted wifi environments like conferences)
            HostName = "ssh.github.com";
            Port = 443;
          };
          "codeberg.org" = {
            User = "git";
            IdentitiesOnly = true;
          };
          "tangled.org" = {
            User = "git";
            IdentitiesOnly = true;
          };
          "*" = {
            ForwardAgent = false;
            AddKeysToAgent = "yes";
            Compression = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = "no";
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = "no";
          }
          // lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
            IgnoreUnknown = "AddKeysToAgent,UseKeychain";
          };
        };
        # Escape hatch allow additional configs in ~/.ssh/config.d/
        includes = [ "config.d/*" ];
      };
    };
}
