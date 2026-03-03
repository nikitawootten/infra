{ ... }:
{
  flake.modules.homeManager.upgrade-diff =
    { pkgs, config, ... }:
    {
      home.activation.diff = config.lib.dag.entryAnywhere ''
        if [[ -v oldGenPath ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff $oldGenPath $newGenPath
        fi
      '';
    };

  flake.modules.nixos.upgrade-diff =
    { pkgs, ... }:
    {
      system.activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        '';
      };
    };

  flake.modules.darwin.upgrade-diff =
    { pkgs, ... }:
    {
      system.activationScripts.diff.text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
}
