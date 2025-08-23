{ pkgs, inputs, lib, config, ... }: {
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = {
    stylix = {
      fonts = {
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
      };

      cursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };
    };
  } // lib.mkIf (!config.stylix.enable) {
    # NOTE: Stylix only imports the home-manager module if enabled
    home-manager.sharedModules =
      [{ imports = [ inputs.stylix.homeModules.stylix ]; }];
  };
}
