{ ... }:
{
  flake.modules.nixos.ssh-server =
    {
      lib,
      config,
      keys,
      ...
    }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkDefault "no";
          PasswordAuthentication = lib.mkDefault false;
        };
      };

      users.users.${config.personal.user.name}.openssh.authorizedKeys.keys = keys.authorized_keys;
    };
}
