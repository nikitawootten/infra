{ pkgs, lib, config, ... }:
let cfg = config.personal.base;
in {
  options.personal.base = { enable = lib.mkEnableOption "base configuration"; };

  config = lib.mkIf cfg.enable {
    time.timeZone = lib.mkDefault "America/New_York";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = { layout = "us"; };

    programs.zsh.enable = true;

    services.fwupd.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [ gnumake wget git tmux vim helix ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    nix = {
      settings = {
        auto-optimise-store = true;
        trusted-users = [ "@wheel" ];
      };
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    };

    nixpkgs.config.allowUnfree = true;

    security.sudo.execWheelOnly = true;

    system.stateVersion = "24.05";
  };
}
