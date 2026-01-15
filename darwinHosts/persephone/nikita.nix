{ pkgs, keys, ... }:
{
  personal.roles.work.enable = true;

  personal.git.signingKey = keys.nikita_persephone;

  home.packages = with pkgs; [ swiftlint ];
}
