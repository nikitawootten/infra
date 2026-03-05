{ ... }:
{
  flake.nixosModules.libvirt =
    { pkgs, config, ... }:
    {
      users.users.${config.personal.user.name}.extraGroups = [ "libvirtd" ];
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            swtpm.enable = true;
            ovmf.enable = true;
            ovmf.packages = [ pkgs.OVMFFull.fd ];
          };
        };
        spiceUSBRedirection.enable = true;
      };

      environment.systemPackages = with pkgs; [
        spice
        spice-gtk
        spice-protocol
        virt-viewer
        virtio-win
        win-spice
      ];
      programs.virt-manager.enable = true;

      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = [ "qemu:///system" ];
              uris = [ "qemu:///system" ];
            };
          };
        }
      ];
    };
}
