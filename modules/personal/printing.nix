{ ... }:
{
  flake.modules.nixos.printing =
    { lib, pkgs, ... }:
    {
      services.printing.enable = lib.mkDefault true;

      services.avahi.enable = true;
      services.avahi.nssmdns4 = true;
      services.avahi.openFirewall = true;

      services.printing.drivers = with pkgs; [ hplip ];
    };
}
