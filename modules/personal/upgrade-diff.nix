{ ... }:
{
  flake.homeModules.upgrade-diff =
    { pkgs, config, ... }:
    {
      home.activation.diff = config.lib.dag.entryAnywhere ''
        if [[ -v oldGenPath ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff $oldGenPath $newGenPath
        fi
      '';
    };

  flake.nixosModules.upgrade-diff =
    { pkgs, ... }:
    {
      system.activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        '';
      };
    };

  flake.darwinModules.upgrade-diff =
    { pkgs, ... }:
    {
      system.activationScripts.diff.text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
}
