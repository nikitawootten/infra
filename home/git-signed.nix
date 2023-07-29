{ ... }:
{
  programs.git = {
    extraConfig = {
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
      user.signingKey = "~/.ssh/id_ed25519_sk";
    };
  };
}
