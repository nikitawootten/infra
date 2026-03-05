{ ... }:
{
  flake.nixosModules.networkmanager =
    { lib, config, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${config.personal.user.name}.extraGroups = [ "networkmanager" ];

      # via https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1473408913
      systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
      systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    };
}
