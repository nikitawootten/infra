{ pkgs, lib, config, username, ... }:
let
  cfg = config.personal.base;
in
{
  options.personal.base = {
    enable = lib.mkEnableOption "base configuration";
  };

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
    services.xserver = {
      layout = "us";
      xkbVariant = "";
    };

    programs.zsh.enable = true;

    users.users.${username} = {
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };

    services.fwupd.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      gnumake
      wget
      git
      tmux
      vim
      helix
    ];

    nix = {
      settings = {
        auto-optimise-store = true;
        trusted-users = [ "@wheel" ];
      };
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    security.sudo.execWheelOnly = true;

    system.stateVersion = "23.11";
  };
}
