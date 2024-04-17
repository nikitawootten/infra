{ lib, config, ... }:
let cfg = config.homelab.observability.grafana;
in {
  options.homelab.observability.grafana =
    config.lib.homelab.mkServiceOptionSet "Grafana" "grafana" cfg;

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server.domain = lib.mkForce cfg.domain;
        # } // lib.mkIf config.homelab.auth.enable {
        #   auth.generic_oauth = let
        #     auth-domain = config.homelab.auth.keycloak.domain;
        #     auth-realm = "lab";
        #   in {
        #     enabled = true;
        #     name = "Keycloak-OAuth";
        #     allow_sign_up = true;
        #     scopes = "openid email profile offline_access roles";
        #     email_attribute_path = "email";
        #     login_attribute_path = "username";
        #     name_attribute_path = "full_name";
        #     auth_url = "${auth-domain}/realms/${auth-realm}/protocol/openid-connect/auth";
        #     token_url = "${auth-domain}/realms/${auth-realm}/protocol/openid-connect/token";
        #     api_url = "${auth-domain}/realms/${auth-realm}/protocol/openid-connect/userinfo";
        #     role_attribute_path = "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";
        #   };
      };
      provision = {
        enable = true;
        datasources.settings.apiVersion = 1;
      };
    };

    services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} =
      {
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

    homelab.observability.homepageConfig.Grafana = {
      priority = lib.mkDefault 1;
      config = {
        description = "Grafana";
        href = "https://${cfg.domain}";
        icon = "grafana.png";
      };
    };
  };
}
