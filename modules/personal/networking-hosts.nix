{ ... }:
{
  flake.darwinModules.networking-hosts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.networking.hosts;

      # Render `{ "127.0.0.1" = [ "a.com" "b.net" ]; }` into hosts-file lines.
      extraLines = lib.concatStringsSep "\n" (
        lib.flatten (lib.mapAttrsToList (ip: hostnames: map (hostname: "${ip}\t${hostname}") hostnames) cfg)
      );

      hostsFile = pkgs.writeText "hosts" (
        ''
          # This file is managed by Nix-Darwin and will be overwritten.

          127.0.0.1       localhost
          255.255.255.255 broadcasthost
          ::1             localhost
        ''
        + lib.optionalString (extraLines != "") "\n${extraLines}\n"
      );
    in
    {
      options.networking.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        example = lib.literalExpression ''
          {
            "127.0.0.1" = [
              "example-blocked-domain.com"
              "another-blocked-site.net"
            ];
          }
        '';
        description = ''
          Mapping of IP addresses to lists of host names written to
          {file}`/etc/hosts`.

          Symlinking {file}`/etc/hosts` into the Nix store breaks some
          applications, so the file is generated in the store and copied into
          place by a launchd daemon at load time.
        '';
      };

      config = {
        launchd.daemons.etc-hosts = {
          script = ''
            /bin/cp ${hostsFile} /etc/hosts
            /usr/sbin/chown root:wheel /etc/hosts
            /bin/chmod 0644 /etc/hosts
          '';
          serviceConfig = {
            RunAtLoad = true;
            KeepAlive = false;
          };
        };
      };
    };
}
