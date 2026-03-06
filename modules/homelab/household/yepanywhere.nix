{ self, inputs, ... }:
{
  flake.nixosModules.homelab-yepanywhere =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.household.yepanywhere;
      kanidmGroup = "yepanywhere_users";
      serviceUrl = "http://127.0.0.1:${toString config.services.yepanywhere.port}";
    in
    {
      imports = [ self.nixosModules.yepanywhere ];

      options.homelab.household.yepanywhere =
        config.lib.homelab.mkServiceOptionSet "YepAnywhere" "yepanywhere" cfg // { };

      config = lib.mkIf cfg.enable {
        services.yepanywhere = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.yepanywhere;
          user = config.personal.user.name;
          group = "users";
          serverSettings = {
            version = 1;
            settings = {
              serviceWorkerEnabled = true;
              persistRemoteSessionsToDisk = false;
              allowedHosts = cfg.domain;
            };
          };
        };

        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          useACMEHost = config.homelab.domain;
          locations."/" = {
            proxyPass = serviceUrl;
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };

        environment.systemPackages = [
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
        ];

        services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
          allowed_groups = [ kanidmGroup ];
        };
        homelab.infra.oauth2-proxy.groups = [ kanidmGroup ];

        homelab.household.homepageConfig.${cfg.name} = {
          priority = lib.mkDefault 12;
          config = {
            description = "Remote Claude Code sessions";
            href = cfg.url;
            icon = "mdi-console";
            siteMonitor = cfg.url;
          };
        };
      };
    };
}
