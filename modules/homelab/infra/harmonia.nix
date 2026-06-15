{ ... }:
{
  flake.nixosModules.homelab-harmonia =
    { lib, config, ... }:
    let
      cfg = config.homelab.infra.harmonia;
    in
    {
      options.homelab.infra.harmonia = config.lib.homelab.mkServiceOptionSet "Harmonia" "cache" cfg // {
        signKeyFile = lib.mkOption {
          type = lib.types.path;
          description = "File containing the nix store signing key";
        };
        port = lib.mkOption {
          type = lib.types.port;
          description = "Port to listen on";
          default = 5001;
        };
      };

      config = lib.mkIf cfg.enable {
        services.harmonia.cache = {
          enable = true;
          signKeyPaths = [ cfg.signKeyFile ];
          settings = {
            bind = "[::]:${toString cfg.port}";
          };
        };

        services.nginx.virtualHosts.${cfg.domain} = {
          forceSSL = true;
          useACMEHost = config.homelab.domain;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };

        homelab.infra.homepageConfig.${cfg.name} = {
          priority = lib.mkDefault 20;
          config = {
            description = "Nix binary cache";
            href = cfg.url;
            icon = "nixos.png";
            siteMonitor = cfg.url;
          };
        };
      };
    };
}
