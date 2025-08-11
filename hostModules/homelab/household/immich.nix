{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.household.immich;
  kanidmGroup = "immich_users";
  kanidmAdminGroup = "immich_admins";
  kanidmGroups = [ kanidmGroup kanidmAdminGroup ];
  groupsClaim = "immich_role";
  clientId = "immich";

  # Runtime config file path
  runtimeConfigFile = "/run/immich/config.json";
in {
  options.homelab.household.immich =
    config.lib.homelab.mkServiceOptionSet "Immich" "immich" cfg // {
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the Immich client secret";
      };
    };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      settings = {
        server.externalDomain = cfg.url;
        oauth = {
          enabled = true;
          autoLaunch = true;
          autoRegister = true;
          inherit clientId;
          clientSecret =
            "\${IMMICH_OAUTH_CLIENT_SECRET}"; # Will be replaced by envsubst
          issuerUrl =
            "https://${config.homelab.infra.kanidm.domain}/oauth2/openid/${clientId}";
          scope = "openid profile email ${groupsClaim}";
          signingAlgorithm = "RS256";
          storageLabelClaim = "preferred_username";
        };
      };
      mediaLocation = "${config.homelab.media.mediaRoot}/immich";
      accelerationDevices = null;
    };

    systemd.services.immich-config-setup = {
      description = "Generate Immich configuration with secrets";
      wantedBy = [ "immich-server.service" ];
      before = [ "immich-server.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        ExecStart = pkgs.writeShellScript "immich-config-setup" ''
          set -euo pipefail

          mkdir -p "$(dirname "${runtimeConfigFile}")"

          if [[ ! -f "${cfg.clientSecretFile}" ]]; then
            echo "Error: Client secret file ${cfg.clientSecretFile} not found"
            exit 1
          fi

          export IMMICH_OAUTH_CLIENT_SECRET="$(cat "${cfg.clientSecretFile}")"

          # The nixpkgs module sets this in services.immich.environment.IMMICH_CONFIG_FILE
          nixpkgs_config_file="${
            lib.optionalString (config.services.immich.settings != null)
            (pkgs.formats.json { }).generate "immich.json"
            config.services.immich.settings
          }"

          if [[ -f "$nixpkgs_config_file" ]]; then
            ${pkgs.envsubst}/bin/envsubst < "$nixpkgs_config_file" > "${runtimeConfigFile}"
          else
            echo "Error: Could not find nixpkgs-generated config file: $nixpkgs_config_file"
            exit 1
          fi

          # Set proper ownership and permissions
          chown ${config.services.immich.user}:${config.services.immich.group} "${runtimeConfigFile}"
          chmod 600 "${runtimeConfigFile}"

          unset IMMICH_OAUTH_CLIENT_SECRET
        '';
      };
    };

    systemd.services.immich-server = {
      environment = { IMMICH_CONFIG_FILE = lib.mkForce runtimeConfigFile; };
      requires = [ "immich-config-setup.service" ];
      after = [ "immich-config-setup.service" ];
    };

    systemd.paths.immich-config-watch = {
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathChanged = cfg.clientSecretFile;
        Unit = "immich-config-setup.service";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.immich.port}";
        recommendedProxySettings = true;
      };
    };

    services.kanidm.provision.groups.${kanidmGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.groups.${kanidmAdminGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.systems.oauth2.${clientId} = {
      displayName = cfg.name;
      originUrl = [
        "${cfg.url}/auth/login"
        "${cfg.url}/user-settings"
        "app.immich:///oauth-callback"
      ];
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps = lib.genAttrs kanidmGroups
        (group: [ "email" "openid" "profile" groupsClaim ]);
      claimMaps.${groupsClaim} = {
        joinType = "array";
        valuesByGroup = {
          ${kanidmGroup} = [ "user" ];
          ${kanidmAdminGroup} = [ "admin" ];
        };
      };
      # immich requires RS256
      enableLegacyCrypto = true;
    };

    homelab.household.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 7;
      config = {
        description = "Photo and video backup";
        href = cfg.url;
        icon = "immich.png";
        siteMonitor = cfg.url;
      };
    };
  };
}
