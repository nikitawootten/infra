{ pkgs, config, lib, ... }:
let cfg = config.personal.roles.security;
in {
  options.personal.roles.security = {
    enable = lib.mkEnableOption "Security tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [ nmap sqlmap sqlitebrowser dbeaver-bin ]
      ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
        burpsuite
        aircrack-ng
        macchanger
        kismet
        iw
        hashcat
        ghidra
      ]);
    # Fix font rendering for burpsuite
    home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
  };
}
