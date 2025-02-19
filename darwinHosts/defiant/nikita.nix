{ pkgs, keys, ... }: {
  personal.roles.work.enable = true;

  personal.git.signingKey = keys.nikita_defiant;
}
