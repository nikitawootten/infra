{ lib, pkgs, config, secrets, ...}:
let
  staticConfig = {
    api.dashboard = true; # exposes the traefik dash to :8080
    providers.docker.exposedbydefault = false;
    providers.file.directory = dynamicConfigDirectory;
    entrypoints = {
      web = {
        address = ":80";
        http.middlewares = [ "https-only@file" ];
      };
      websecure = {
        address = ":443";
        http.tls = {
          certResolver = "primary";
          domains = [
            {
              main = "${config.personal.lab.domain}";
              sans = "*.${config.personal.lab.domain}";
            }
          ];
        };
      };
    };
    certificatesResolvers = {
      primary = {
        acme = {
          email = "nikita.wootten@gmail.com";
          storage = "/letsencrypt/acme-primary.json";
          dnsChallenge.provider = "cloudflare";
          dnsChallenge.delayBeforeCheck = 0;
        };
      };
    };
  };
  staticConfigFile = builtins.toFile "traefik.yaml" (builtins.toJSON staticConfig);
  dynamicConfigDirectory = "/etc/traefik/dynamic";
  # For defining middlewares
  dynamicConfig = {
    http.middlewares = {
      local-https.chain.middlewares = [ "known-ips" "https-only" ];
      https-only.redirectScheme.scheme = "https";
      known-ips.ipWhiteList.sourceRange = [
        "10.69.0.0/24"
        # Tailscale subnet https://tailscale.com/kb/1015/100.x-addresses/
        "100.64.0.0/10"
      ];
      # https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/#forwardauth-with-static-upstreams-configuration
      auth-headers.headers = {
        sslRedirect = true;
        stsSeconds = 315360000;
        browserXssFilter = true;
        contentTypeNosniff = true;
        forceSTSHeader = true;
        sslHost = config.personal.lab.domain;
        stsIncludeSubdomains = true;
        stsPreload = true;
        frameDeny = true;
      };
      oauth-auth-redirect.forwardAuth = {
        address = "https://${config.lib.lab.mkServiceSubdomain "oauth"}/";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-Auth-Request-Access-Token" "Authorization" ];
      };
      oauth-auth-no-redirects.forwardAuth = {
        address = "https://${config.lib.lab.mkServiceSubdomain "oauth"}/oauth2/auth";
        trustForwardHeader = true;
        authResponseHeaders = [ "X-Auth-Request-Access-Token" "Authorization" ];
      };
    };
  };
  dynamicConfigFile = builtins.toFile "traefik_provider.yaml" (builtins.toJSON dynamicConfig);
in
{
  lib.lab.mkTraefikLabels = options: (
    let
      name = options.name;
      subdomain = if builtins.hasAttr "subdomain" options then options.subdomain else options.name;
      # created if port is specified
      service = if builtins.hasAttr "service" options then options.service else options.name;
      host = if (builtins.hasAttr "root" options && options.root)
        then "${config.personal.lab.domain}"
        else config.lib.lab.mkServiceSubdomain subdomain;
      forwardAuth = (builtins.hasAttr "forwardAuth" options && options.forwardAuth);
    in
    {
      "traefik.enable" = "true";
      "traefik.http.routers.${name}.rule" = "Host(`${host}`)";
      "traefik.http.routers.${name}.entrypoints" = "web,websecure";
      # TODO http -> https middleware redirect
    } // lib.attrsets.optionalAttrs (builtins.hasAttr "port" options) {
      "traefik.http.routers.${name}.service" = service;
      "traefik.http.services.${service}.loadbalancer.server.port" = "${options.port}";
    } // lib.attrsets.optionalAttrs (builtins.hasAttr "service" options) {
      "traefik.http.routers.${name}.service" = service;
    } // lib.attrsets.optionalAttrs (builtins.hasAttr "middleware" options) {
      "traefik.http.routers.${name}.middlewares" = "${options.middleware}";
    } // lib.attrsets.optionalAttrs forwardAuth {
      "traefik.http.routers.${name}.middlewares" = "oauth-auth-redirect@file";
      "traefik.http.routers.${name}-auth-redirect.rule" = "Host(`${host}`) && PathPrefix(`/oauth2/`)";
      "traefik.http.routers.${name}-auth-redirect.middlewares" = "auth-headers@file";
      # TODO can the name be determed a bit more reliably?
      "traefik.http.routers.${name}-auth-redirect.service" = "oauth2-proxy-lab";
    });

  age.secrets.traefik.file = secrets.traefik;

  virtualisation.arion.projects.lab.settings.services.traefik = {
    image.command = [
      "${pkgs.traefik}/bin/traefik"
    ];
    image.contents = with pkgs; [
      cacert
      bashInteractive
    ];
    service = {
      container_name = "traefik";
      stop_signal = "SIGINT";
      ports = [
        "80:80"
        "443:443"
      ];
      volumes = [
        "${staticConfigFile}:/etc/traefik/traefik.yaml"
        "${dynamicConfigFile}:${dynamicConfigDirectory}/config.yaml"
        "/backplane/applications/letsencrypt/:/letsencrypt"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      env_file = [ 
        config.age.secrets.traefik.path
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "traefik";
        subdomain = "charon";
        service = "api@internal";
        forwardAuth = true;
      } // config.lib.lab.mkHomepageLabels {
        name = "Charon";
        description = "Traefik: HTTP router";
        group = "Infrastructure";
        subdomain = "charon";
        icon = "traefik.png";
      };
      restart = "unless-stopped";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80    # web entrypoint
    443   # websecure entrypoint
  ];
}