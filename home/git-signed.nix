{ ... }:

{
  programs.git = {
    extraConfig = {
      commit.gpgsign = true;
      user.signingKey = "0xAC4A02D80C2F00DC82EE1EFA0D418BA5CA014A62";
    };
  };
}
