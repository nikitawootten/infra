{ lib, config, ... }:
let
  cfg = config.personal.printing;
in
{
  options.personal.printing = {
    enable = lib.mkEnableOption "printing configuration";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = lib.mkDefault true;
  };
}
