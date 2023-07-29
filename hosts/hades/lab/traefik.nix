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
              main = "${config.networking.hostName}.${config.lib.lab.domain}";
              sans = "*.${config.networking.hostName}.${config.lib.lab.domain}";
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
          # Tailscale subnet https://tailscale.com/kb/1015/100.x-addresses/
          "100.64.0.0/10"
        ];
      };
    };
  };
  dynamicConfigFile = builtins.toFile "traefik_provider.yaml" (builtins.toJSON dynamicConfig);
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
        then "${config.networking.hostName}.${config.lib.lab.domain}"
        else "${subdomain}.${config.networking.hostName}.${config.lib.lab.domain}";
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
        "8080:8080"
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
      } // config.lib.lab.mkHomepageLabels {
        name = "Charon";
        description = "Traefik: HTTP router";
        group = "Infrastructure";
        subdomain = "charon";
        icon = "traefik.png";
      } // {
        "homepage.widget.type" = "traefik";
        "homepage.widget.url" = "https://charon.${config.networking.hostName}.${config.lib.lab.domain}";
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