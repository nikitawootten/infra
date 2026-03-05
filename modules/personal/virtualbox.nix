{ ... }:
{
  flake.nixosModules.virtualbox =
    { config, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableExtensionPack = true;
      users.users.${config.personal.user.name}.extraGroups = [ "vboxusers" ];
    };
}
