{ inputs, ... }:
{
  flake.nixosModules.flatpak =
    { config, ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      services.flatpak = {
        enable = true;
        # Common packages that I use
        packages = [
          "com.discordapp.Discord"
          "com.google.Chrome"
          "org.libreoffice.LibreOffice"
          "org.signal.Signal"
          "md.obsidian.Obsidian"
          "com.spotify.Client"
        ];
        overrides.global.Environment.TZ = config.time.timeZone;
        uninstallUnmanaged = true;
        update.auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
    };
}
