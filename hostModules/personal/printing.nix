{ lib, config, pkgs, ... }:
let
  cfg = config.personal.printing;
in
{
  options.personal.printing = {
    enable = lib.mkEnableOption "printing configuration";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = lib.mkDefault true;

    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.openFirewall = true;

    services.printing.drivers = with pkgs; [ hplip ];
  };
}
