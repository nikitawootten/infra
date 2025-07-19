{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.play;
in {
  options.personal.roles.play = {
    enable = lib.mkEnableOption "Play related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    # PrismLauncher installed via brew cask on MacOS
    home.packages = with pkgs;
      [ ] ++ lib.lists.optionals pkgs.stdenv.isLinux [ prismlauncher ];
  };
}
