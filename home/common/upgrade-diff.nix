{ lib, config, pkgs, ... }:
let
  cfg = config.upgrade-diff;
in
{
  options.upgrade-diff = {
    enable = lib.mkEnableOption "upgrade diff notification";
  };

  config = lib.mkIf cfg.enable {
    home.activation.diff = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff $oldGenPath $newGenPath
    '';
  };
}