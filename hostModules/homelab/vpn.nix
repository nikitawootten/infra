{ lib, config, inputs, ... }:
let
  cfg = config.homelab.vpn;
in
{
  imports = [
    inputs.vpnconfinement.nixosModules.default
  ];

  options.homelab.vpn = {
    enable = lib.mkEnableOption "Enable VPN confinement";
    wireguardConfigFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the WireGuard configuration file";
    };
    namespace = lib.mkOption {
      type = lib.types.str;
      description = "Namespace to use for the VPN";
      default = "wg";
    };
    accessibleFrom = lib.mkOption {
      type = lib.types.str;
      description = "Networks that should be able to access the VPN";
    };
  };

  config = lib.mkIf cfg.enable {
    vpnnamespaces.${cfg.namespace} = {
      enable = true;
      wireguardConfigFile = cfg.wireguardConfigFile;
      accessibleFrom = [ cfg.accessibleFrom ];
    };
  };
}
