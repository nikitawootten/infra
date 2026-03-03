{ inputs, ... }:
{
  flake.modules.nixos.flatpak =
    { ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      services.flatpak = {
        enable = true;
        # Common packages that I use
        packages = [
          "com.discordapp.Discord"
          "com.google.Chrome"
          "com.spotify.Client"
          "org.libreoffice.LibreOffice"
          "org.signal.Signal"
          "md.obsidian.Obsidian"
        ];
        uninstallUnmanaged = true;
        update.auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
    };
}
