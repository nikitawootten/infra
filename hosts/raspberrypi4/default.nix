{ self, username, nixos-generators, ... }:
{
  imports = [
    self.nixosModules.raspi4sd
    # By default, configure locale and ssh server, and some basic packages
    self.nixosModules.personal
    nixos-generators.nixosModules.all-formats
  ];

  personal.tailscale.enable = false;

  users.users.${username} = {
    # DEFINITELY change this :)
    initialPassword = "raspberry";
  };
  services.openssh.settings.PasswordAuthentication = true;
}
