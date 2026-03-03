{ ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          nmap
          sqlmap
          sqlitebrowser
          dbeaver-bin
        ]
        ++ lib.lists.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            burpsuite
            aircrack-ng
            macchanger
            kismet
            iw
            hashcat
            ghidra
          ]
        );
      # Fix font rendering for burpsuite
      home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    };
in
{
  flake.modules.homeManager.role-security = hmModule;

  flake.modules.nixos.role-security =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home-manager.sharedModules = [ hmModule ];

      users.users.${config.personal.user.name}.extraGroups = [ "wireshark" ];
      programs.wireshark.enable = lib.mkForce true;
      programs.wireshark.package = lib.mkDefault pkgs.wireshark;
    };

  flake.modules.darwin.role-security =
    { ... }:
    {
      home-manager.sharedModules = [ hmModule ];

      homebrew.brews = [ "ipsw" ];
      homebrew.casks = [ "wireshark-app" ];
    };
}
