{ config, lib, ... }:
let
  cfg = config.homelab.household.actual;
  kanidmGroup = "actual_users";
in {
  options.homelab.household.actual =
    config.lib.homelab.mkServiceOptionSet "Actual Budget" "actual" cfg // {
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the Actual Budget client secret";
      };
    };

  config = lib.mkIf cfg.enable {
    services.actual = {
      enable = true;
      settings.port = 3001; # Default conflicts with Grafana
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass =
          "http://127.0.0.1:${toString config.services.actual.settings.port}";
        recommendedProxySettings = true;
      };
    };

    services.kanidm.provision.groups.${kanidmGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.systems.oauth2.actual = {
      displayName = cfg.name;
      originUrl = "${cfg.url}/openid/callback";
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps.${kanidmGroup} = [ "email" "openid" "profile" ];
      # Actual requires RS256
      enableLegacyCrypto = true;
    };

    homelab.household.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 10;
      config = {
        description = "Budgeting and personal finance tool";
        href = cfg.url;
        icon = "actual-budget.png";
        siteMonitor = cfg.url;
      };
    };
  };
}
