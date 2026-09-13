{ ... }:
{
  flake.nixosModules.homelab-flaresolverr =
    { lib, config, ... }:
    let
      cfg = config.homelab.media.flaresolverr;
    in
    {
      options.homelab.media.flaresolverr = {
        enable = lib.mkEnableOption "FlareSolverr";
      };

      config = lib.mkIf cfg.enable {
        services.flaresolverr.enable = true;
      };
    };
}
