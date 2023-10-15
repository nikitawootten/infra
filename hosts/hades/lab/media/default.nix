{ lib, config, ... }:
let
  cfg = config.personal.lab.media;
in
{
  options.personal.lab.media = {
    media-dir = lib.mkOption {
      type = lib.types.str;
      description = "The media directory";
      default = "/storage2/media";
    };
  };

  imports = [
    ./ersatztv.nix
    ./freshrss.nix
    ./jellyfin.nix
    ./prowlarr.nix
    ./radarr.nix
    ./readarr.nix
    ./sonarr.nix
    ./transmission-ovpn.nix
  ];
}
