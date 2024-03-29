{ inputs, lib, config, ... }:
let
  cfg = config.personal.lab;
in
{
  options.personal.lab = {
    base-domain = lib.mkOption {
      type = lib.types.str;
      description = "The base domain, or search path of the network";
      default = "arpa.nikita.computer";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "The subdomain that all services will be deployed to";
      default = config.networking.hostName;
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain that all services will be deployed to";
      default = "${cfg.subdomain}.${cfg.base-domain}";
      readOnly = true;
    };
    config-dir = lib.mkOption {
      type = lib.types.str;
      description = "The configuration directory";
      default = "/storage/config";
    };
  };

  config = {
    virtualisation.arion.backend = "docker";
    lib.lab.mkServiceSubdomain = subdomain: "${subdomain}.${config.personal.lab.domain}";
    lib.lab.mkConfigDir = name: "${config.personal.lab.config-dir}/${name}";

    personal.lab.homepage.infrastructure-services = [
      {
        Pandora = {
          icon = "pfsense.png";
          href = "https://pandora.${config.personal.lab.base-domain}";
          description = "pfSense Firewall";
          # TODO set up pfSense API
          # widget = {
          #   type = "pfsense";
          #   url = "https://pandora.arpa.nikita.computer";
          #   username = "";
          #   password = "";
          #   wan = "WAN";
          # };
        };
      }
      {
        IDRAC = {
          icon = "idrac.png";
          href = "https://idrac-${config.personal.lab.subdomain}.${config.personal.lab.base-domain}";
          description = "Dell Remote Management";
        };
      }
    ];
  };

  imports = [
    inputs.arion.nixosModules.arion
    inputs.agenix.nixosModules.default
    ./auth
    ./infra
    ./media
    ./actual.nix
    ./grocy.nix
    ./homepage.nix
  ];
}
