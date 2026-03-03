{ pkgs, keys, ... }:
{
  personal.git.signingKey = keys.nikita_persephone;

  home.packages = with pkgs; [ swiftlint ];
}
