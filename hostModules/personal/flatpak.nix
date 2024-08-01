{ inputs, lib, config, ... }:
let cfg = config.personal.flatpak;
in {
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.personal.flatpak = {
    enable = lib.mkEnableOption "manage installed flatpak";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      # Common packages that I use
      packages = [
        "com.brave.Browser"
        "com.discordapp.Discord"
        "com.google.Chrome"
        "com.logseq.Logseq"
        "com.slack.Slack"
        "com.spotify.Client"
        "org.libreoffice.LibreOffice"
        "org.signal.Signal"
      ];
      remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }];
    };
  };
}
