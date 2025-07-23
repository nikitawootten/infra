{ config, lib, ... }:
let
  cfg = config.homelab.media.audiobookshelf;
  kanidmGroup = "audiobookshelf_users";
  kanidmAdminGroup = "audiobookshelf_admins";
  kanidmClaim = "claim_groups";
in {
  options.homelab.media.audiobookshelf =
    config.lib.homelab.mkServiceOptionSet "AudioBookShelf" "audio" cfg // {
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the AudioBookShelf client secret";
      };
    };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      group = config.homelab.media.group;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass =
          "http://127.0.0.1:${toString config.services.audiobookshelf.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    services.kanidm.provision.groups.${kanidmGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.groups.${kanidmAdminGroup} = {
      overwriteMembers = false;
    };
    services.kanidm.provision.systems.oauth2.audiobookshelf = {
      displayName = "AudioBookShelf";
      originUrl = [
        "${cfg.url}/auth/openid/callback"
        "${cfg.url}/auth/openid/mobile-redirect"
      ];
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps.${kanidmGroup} = [ "email" "openid" "profile" kanidmClaim ];
      scopeMaps.${kanidmAdminGroup} =
        [ "email" "openid" "profile" kanidmClaim ];
      claimMaps.${kanidmClaim}.valuesByGroup = {
        ${kanidmGroup} = [ "user" ];
        ${kanidmAdminGroup} = [ "admin" ];
      };
    };

    homelab.media.homepageConfig.AudioBookShelf = {
      priority = lib.mkDefault 6;
      config = {
        description = "AudioBookShelf";
        href = cfg.url;
        icon = "audiobookshelf.png";
      };
    };
  };
}
