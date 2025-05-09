{ self, lib, config, ... }:
let cfg = config.homelab.homepage;
in {
  imports = [ self.nixosModules.homepage-declarative ];

  options.homelab.homepage = {
    enable = lib.mkEnableOption "Homepage dashboard";
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.domain;
      description = "Homepage domain";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      enable-declarative = true;
      allowedHosts = cfg.domain;
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/".proxyPass = "http://127.0.0.1:${
          toString config.services.homepage-dashboard.listenPort
        }";
    };
  };
}
