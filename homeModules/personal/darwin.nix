{ pkgs, lib, ... }: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Disabling for now due to lack of SSH resident key support in MacOS's packaged SSH agent
    programs.git.settings.commit.gpgsig = lib.mkForce false;

    targets.darwin.copyApps = {
      enable = true;
      enableChecks = true;
    };
    targets.darwin.linkApps.enable = false;
  };
}
