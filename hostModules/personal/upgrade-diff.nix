{ lib, config, pkgs, ... }:
let
  cfg = config.personal.upgrade-diff;
in
{
  options.personal.upgrade-diff = {
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