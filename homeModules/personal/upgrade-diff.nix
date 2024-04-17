{ lib, config, pkgs, ... }:
let cfg = config.personal.upgrade-diff;
in {
  options.personal.upgrade-diff = {
    enable = lib.mkEnableOption "upgrade diff notification";
  };

  config = lib.mkIf cfg.enable {
    home.activation.diff = config.lib.dag.entryAnywhere ''
      if [[ -v oldGenPath ]]; then
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff $oldGenPath $newGenPath
      fi
    '';
  };
}
