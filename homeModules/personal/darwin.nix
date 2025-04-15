{ pkgs, lib, ... }: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Disabling for now due to lack of SSH resident key support in MacOS's packaged SSH agent
    programs.git.extraConfig.commit.gpgsig = lib.mkForce false;
  };
}
