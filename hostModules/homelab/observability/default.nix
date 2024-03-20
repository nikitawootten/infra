{ lib, config, ... }:
let
  cfg = config.homelab.observability;
in
{
  imports = [
    ./grafana.nix
    ./prometheus.nix
    ./loki.nix
  ];

  options.homelab.observability = {
    enable = lib.mkEnableOption "Enable basic observability stack";
  };

  config = lib.mkIf cfg.enable {
    homelab.observability.grafana.enable = true;
    homelab.observability.prometheus.enable = true;
    homelab.observability.loki.enable = true;
  };
}
