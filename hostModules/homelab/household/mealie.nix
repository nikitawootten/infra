{ config, lib, ... }:
let
  cfg = config.homelab.household.mealie;
  kanidmGroup = "mealie_users";
  kanidmAdminGroup = "mealie_admins";
  kanidmGroups = [
    kanidmGroup
    kanidmAdminGroup
  ];
  groupsClaim = "roles";
  clientId = "mealie";
in
{
  options.homelab.household.mealie = config.lib.homelab.mkServiceOptionSet "Mealie" "mealie" cfg // {
    clientSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing the Mealie client secret";
    };
    envFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing sensitive environment variables";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      settings = {
        # OIDC configuration
        OIDC_AUTH_ENABLED = true;
        OIDC_SIGNUP_ENABLED = true;
        OIDC_AUTO_REDIRECT = true;
        OIDC_USER_CLAIM = "preferred_username";
        OIDC_CLIENT_ID = clientId;
        # OIDC_CLIENT_SECRET provided via envFile
        OIDC_USER_GROUP = kanidmGroup;
        OIDC_ADMIN_GROUP = kanidmAdminGroup;
        OIDC_GROUPS_CLAIM = groupsClaim;
        OIDC_CONFIGURATION_URL = "https://${config.homelab.infra.kanidm.domain}/oauth2/openid/${clientId}/.well-known/openid-configuration";
      };
      credentialsFile = cfg.envFile;
      database.createLocally = true;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
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
      originUrl = "${cfg.url}/login";
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps = lib.genAttrs kanidmGroups (group: [
        "email"
        "openid"
        "profile"
        groupsClaim
      ]);
      claimMaps.${groupsClaim} = {
        joinType = "array";
        valuesByGroup = lib.genAttrs kanidmGroups (group: [ group ]);
      };
      # Mealie requires RS256
      enableLegacyCrypto = true;
    };

    homelab.household.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 5;
      config = {
        description = "Meal planning and recipe management";
        href = cfg.url;
        icon = "mealie.png";
        siteMonitor = cfg.url;
        widget = {
          type = "mealie";
          url = cfg.url;
          key = "{{HOMEPAGE_VAR_MEALIE_API_KEY}}";
          version = 2;
        };
      };
    };
  };
}
