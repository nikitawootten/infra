{
  pkgs,
  self,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.personal
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  personal.roles.play.enable = true;
  personal.roles.security.enable = true;
  personal.roles.work.enable = true;

  personal.networkmanager.enable = true;
  personal.flatpak.enable = true;
  personal.zsa.enable = true;

  # Bootloader
  environment.systemPackages = with pkgs; [ sbctl ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."luks-f190f8c5-0961-45c4-a785-d7f3692e65f8".device =
    "/dev/disk/by-uuid/f190f8c5-0961-45c4-a785-d7f3692e65f8";

  boot.supportedFilesystems = [ "ntfs" ];

  # Rotate the screen
  # (GPD pocket 2 uses a tablet screen, so the default orientation is sideways)
  boot.kernelParams = [
    "fbcon=rotate:1"
    "video=eDP-1:panel_orientation=right_side_up"
  ];
  # Set a usable console font size
  console = {
    # ls /etc/kbd/consolefonts
    font = "ter-132n";
    packages = with pkgs; [ terminus_font ];
    earlySetup = true;
  };

  fonts.fontconfig.subpixel.rgba = "vbgr";

  networking.hostName = "cochrane";

  personal.niri.enable = true;
  home-manager.sharedModules = [
    {
      programs.niri.settings = {
        outputs.eDP-1 = {
          scale = 1.5;
        };
        layout.gaps = 8;
        layout.border.width = 2;
      };
    }
  ];
  programs.nix-ld.enable = true;

  stylix.enable = true;
  stylix.image = pkgs.fetchurl {
    url = "https://github.com/linuxdotexe/nordic-wallpapers/blob/master/wallpapers/ign-0008.png?raw=true";
    sha256 = "sha256-/ybcRRleApkw3JXQTZgOsYznRwS7pIRvZYp0Vyls7i4=";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
  stylix.polarity = "dark";

  home-manager.users.${config.personal.user.name} = {
    home.packages = with pkgs; [
      tor-browser
      zed-editor
    ];
    personal.bridge.enable = true;
    programs.git.settings.credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
  };
}
