{ lib, config, pkgs, ... }:
let
  cfg = config.upgrade-diff;
in
{
  options.upgrade-diff = {
    enable = lib.mkEnableOption "upgrade diff notification";
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
  };
}