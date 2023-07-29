{ lib, pkgs, config, hostname, ...}:
let
  env_secret = "traefik.env.age";
  staticConfig = {
    api.dashboard = true; # exposes the traefik dash to :8080
    providers.docker.exposedbydefault = false;
    entrypoints = {
      web.address = ":80";
      websecure = {
        address = ":443";
        http.tls = {
          certResolver = "primary";
          domains = [
            {
              main = "${hostname}.${config.lib.lab.domain}";
              sans = "*.${hostname}.${config.lib.lab.domain}";
            }
          ];
        };
      };
    };
    http.middlewares = {
      local-https = {
        chain.middlewares = [
          "known-ips"
          "https-only"
        ];
      };
      https-only = {
        redirectScheme.scheme = "https";
      };
      known-ips = {
        ipWhiteList.sourceRange = [
          "10.69.0.0/24"
        ];
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
  configFile = builtins.toFile "traefik.yaml" (builtins.toJSON staticConfig);
in
{
  lib.lab.domain = "arpa.nikita.computer";
  lib.lab.mkTraefikLabels = options: (
    let
      name = options.name;
      subdomain = if builtins.hasAttr "subdomain" options then options.subdomain else options.name;
      # created if port is specified
      service = if builtins.hasAttr "service" options then options.service else options.name;
      host = if (builtins.hasAttr "root" options && options.root)
        then "${hostname}.${config.lib.lab.domain}"
        else "${subdomain}.${hostname}.${config.lib.lab.domain}";
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
    });

  age.secrets."${env_secret}".file = ../../secrets/${env_secret};

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
        "8080:8080"
      ];
      volumes = [
        "${configFile}:/etc/traefik/traefik.yaml"
        "/backplane/applications/letsencrypt/:/letsencrypt"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      env_file = [ 
        config.age.secrets."${env_secret}".path
      ];
      labels = config.lib.lab.mkTraefikLabels {
        name = "traefik";
        subdomain = "charon";
        service = "api@internal";
      } // config.lib.lab.mkHomepageLabels {
        name = "Charon";
        description = "Traefik HTTP router";
        group = "Infrastructure";
        subdomain = "charon";
        icon = "traefik.png";
      } // {
        "homepage.widget.type" = "traefik";
        "homepage.widget.url" = "https://charon.${hostname}.${config.lib.lab.domain}";
      };
      useHostStore = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80    # web entrypoint
    443   # websecure entrypoint
    8080  # traefik spacial entrypoint
  ];
}