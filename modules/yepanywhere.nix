{ ... }:
{
  flake.nixosModules.yepanywhere =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.yepanywhere;
      settingsFile = pkgs.writeText "server-settings.json" (builtins.toJSON cfg.serverSettings);
    in
    {
      options.services.yepanywhere = {
        enable = lib.mkEnableOption "YepAnywhere";

        package = lib.mkOption {
          type = lib.types.package;
          description = "The YepAnywhere package to use.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 3400;
          description = "Port for the YepAnywhere server.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "yepanywhere";
          description = "User account under which YepAnywhere runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "yepanywhere";
          description = "Group under which YepAnywhere runs.";
        };

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/yepanywhere";
          description = "Directory where YepAnywhere stores its data.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the server port in the firewall.";
        };

        serverSettings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = ''
            Attrset written to server-settings.json in the data directory.
            Only written if non-empty.
          '';
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = ''
            Additional environment variables for the YepAnywhere service.
            These are merged with and can override the typed options above.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        users.users.${cfg.user} = lib.mkIf (cfg.user == "yepanywhere") {
          isSystemUser = true;
          group = cfg.group;
          home = cfg.dataDir;
        };

        users.groups.${cfg.group} = lib.mkIf (cfg.group == "yepanywhere") { };

        systemd.tmpfiles.rules = [
          "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -"
        ];

        systemd.services.yepanywhere = {
          description = "YepAnywhere";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            PORT = toString cfg.port;
            YEP_ANYWHERE_DATA_DIR = cfg.dataDir;
            LOG_PRETTY = "false";
            NODE_ENV = "production";
          }
          // cfg.environment;

          preStart = lib.mkIf (cfg.serverSettings != { }) ''
            cp ${settingsFile} ${cfg.dataDir}/server-settings.json
          '';

          serviceConfig = {
            ExecStart = lib.getExe cfg.package;
            Restart = "on-failure";
            RestartSec = 5;
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = cfg.dataDir;
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
      };
    };
}
