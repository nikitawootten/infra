{ lib, config, ... }:
let
  cfg = config.homelab.auth.keycloak;
in
{
  options.homelab.auth.keycloak = (config.lib.homelab.mkServiceOptionSet "Keycloak" "auth" cfg) // {
    databasePasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "The DB password file";
    };
    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The HTTP port to bind to";
    };
    httpsPort = lib.mkOption {
      type = lib.types.int;
      default = 8443;
      description = "The HTTPS port to bind to";
    };
  };

  config = lib.mkIf cfg.enable {
    services.keycloak = {
      enable = true;
      
      database = {
        createLocally = true;
        type = "postgresql";
        passwordFile = cfg.databasePasswordFile;
      };
      
      settings = {
        hostname = cfg.domain;
        proxy = "edge";
        http-port = cfg.httpPort;
        https-port = cfg.httpsPort;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.httpPort}";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_protocol_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $host;
        '';
      };
    };
  };
}
