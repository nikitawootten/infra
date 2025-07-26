{ lib, config, ... }:
let
  cfg = config.homelab.infra.grafana;
  clientId = "grafana";
  adminGroup = "grafana_admins";
  editorGroup = "grafana_editors";
  groups = [ adminGroup editorGroup ];
  idp = let domain = config.homelab.infra.kanidm.domain;
  in {
    # Thanks to @griffi-gh for this snippet
    # Via https://github.com/girl-pp-ua/nixos-infra/blob/f06b49cc501d9e4cd7fb77345739a9efb5389deb/lib/idp.nix
    oidc_discovery_prefix = "https://${domain}/oauth2/openid/${clientId}";
    oidc_discovery =
      "https://${domain}/oauth2/openid/${clientId}/.well-known/openid-configuration";
    rfc8144_authorization_server_metadata =
      "https://${domain}/oauth2/openid/${clientId}/.well-known/oauth-authorization-server";
    user_auth = "https://${domain}/ui/oauth2";
    api_auth = "https://${domain}/oauth2/authorise";
    token_endpoint = "https://${domain}/oauth2/token";
    rfc7662_token_introspection = "https://${domain}/oauth2/token/introspect";
    rfc7662_token_revocation = "https://${domain}/oauth2/token/revoke";
    oidc_issuer_uri = "https://${domain}/oauth2/openid/${clientId}";
    oidc_user_info = "https://${domain}/oauth2/openid/${clientId}/userinfo";
    token_signing_public_key =
      "https://${domain}/oauth2/openid/${clientId}/public_key.jwk";
  };
in {
  options.homelab.infra.grafana =
    config.lib.homelab.mkServiceOptionSet "Grafana" "grafana" cfg // {
      clientSecretFile = lib.mkOption {
        type = lib.types.path;
        description = "File containing the Grafana client secret";
      };
    };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server.domain = lib.mkForce cfg.domain;
        server.root_url = lib.mkForce cfg.url;
        auth.disable_login_form = true;
        auth.disable_signout_menu = true;
        "auth.basic".enabled = false;
        "auth.generic_oauth" = {
          enabled = true;
          name = "Kanidm";
          client_id = clientId;
          client_secret = "$__file{${cfg.clientSecretFile}}";
          auto_login = true;
          allow_sign_up = true;
          allow_assign_grafana_admin = true;
          scopes = "openid email profile roles";
          email_attribute_path = "email";
          login_attribute_path = "preferred_username";
          name_attribute_path = "full_name";
          auth_url = idp.user_auth;
          token_url = idp.token_endpoint;
          api_url = idp.oidc_user_info;
          use_pkce = true;
          role_attribute_path =
            "contains(roles[*], '${adminGroup}') && 'Admin' || contains(roles[*], '${editorGroup}') && 'Editor' || 'Viewer'";
        };
      };
      provision = {
        enable = true;
        datasources.settings.apiVersion = 1;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://${
            toString config.services.grafana.settings.server.http_addr
          }:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    services.kanidm.provision.groups =
      lib.genAttrs groups (_: { overwriteMembers = false; });
    services.kanidm.provision.systems.oauth2.${clientId} = {
      displayName = "Grafana";
      originUrl = "${cfg.url}/login/generic_oauth";
      originLanding = cfg.url;
      preferShortUsername = true;
      basicSecretFile = cfg.clientSecretFile;
      scopeMaps =
        lib.genAttrs groups (group: [ "email" "openid" "profile" "roles" ]);
      claimMaps.roles = {
        joinType = "array";
        valuesByGroup = lib.genAttrs groups (group: [ group ]);
      };
    };

    homelab.infra.homepageConfig.${cfg.name} = {
      priority = lib.mkDefault 5;
      config = {
        description = "Data visualization and monitoring";
        href = cfg.url;
        icon = "grafana.png";
        siteMonitor = cfg.url;
      };
    };

    topology.self.services.grafana = {
      info = lib.mkForce "";
      details.listen.text = lib.mkForce cfg.domain;
    };

    systemd.services.grafana.after =
      lib.optionals config.homelab.infra.kanidm.enable [ "kanidm.service" ];
  };
}
