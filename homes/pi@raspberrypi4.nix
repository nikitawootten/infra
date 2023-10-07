{ self, ... }: {
  imports = [
    self.homeModules.personal
  ];

  # For now, this has too many personal settings
  # TODO: separate configuration and identity
  personal.git.enable = false;
}
