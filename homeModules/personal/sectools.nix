{ lib, config, pkgs, ... }:
let cfg = config.personal.sectools;
in {
  options.personal.sectools = {
    enable = lib.mkEnableOption "install additional security tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [ nmap sqlmap sqlitebrowser hashcat ghidra dbeaver-bin ]
      ++ lib.lists.optionals pkgs.stdenv.isLinux
      (with pkgs; [ burpsuite aircrack-ng macchanger kismet iw ]);
    # Fix font rendering for burpsuite
    home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
  };
}
