{ ... }:
{
  flake.nixosModules.docker =
    { config, ... }:
    {
      virtualisation.docker.enable = true;
      users.users.${config.personal.user.name}.extraGroups = [ "docker" ];
    };
}
