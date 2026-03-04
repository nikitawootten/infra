# Adopted from https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
{ ... }:
{
  flake.modules.nixos.homelab-samba =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.samba;
    in
    {
      options.homelab.samba = {
        enable = lib.mkEnableOption "Enable samba config";
      };

      config = lib.mkIf cfg.enable {
        services.samba = {
          enable = true;
          openFirewall = true;
          settings.global = {
            "server smb encrypt" = "required";
            # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
            "server min protocol" = "SMB3_00";
          };
        };

        services.avahi = {
          enable = true;
          openFirewall = true;
          publish.enable = true;
          publish.userServices = true;
          nssmdns4 = true;
        };

        services.samba-wsdd = {
          enable = true;
          openFirewall = true;
        };

        networking.firewall.allowPing = true;
      };
    };
}
