{ pkgs, lib, config, ... }: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation = {
      aliasHomeManagerApplications =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
          rm -rf "$app_folder"
          mkdir -p "$app_folder"
          find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
            app_target="$app_folder/$(basename "$app")"
            real_app="$(readlink "$app")"
            echo "mkalias \"$real_app\" \"$app_target\"" >&2
            $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
          done
        '';
    };

    # Disabling for now due to lack of SSH resident key support in MacOS's packaged SSH agent
    programs.git.extraConfig.commit.gpgsig = lib.mkForce false;
  };
}
