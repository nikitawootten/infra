{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet mkRouter mkSwitch mkDevice mkConnection;
in {
  networks.home = {
    name = "Home Network";
    cidrv4 = "10.69.0.1/24";
  };

  nodes.internet = mkInternet { connections = mkConnection "router" "wan1"; };

  nodes.router = mkRouter "pandora" {
    info = "Zimaboard running pfSense";
    interfaceGroups = [ [ "eth0" ] [ "wan1" ] ];
    connections.eth0 = mkConnection "switch" "eth0";
    interfaces.eth0 = {
      addresses = [ "10.69.0.1" ];
      network = "home";
    };
  };

  nodes.switch = mkSwitch "switch" {
    info = "TP-Link gigabit managed switch";
    interfaceGroups = [[ "eth0" "eth1" "eth2" "eth3" ]];

    connections.eth1 = mkConnection "iris" "end0";
    connections.eth2 = mkConnection "hades" "eno1";
    connections.eth3 = mkConnection "ap1" "eth0";
  };

  nodes.ap1 = mkDevice "access-point-1" {
    info = "TP-Link EAP610";
    interfaceGroups = [[ "eth0" "wlan0" ]];

    connections.wlan0 = mkConnection "dionysus" "wlp5s0";
  };
}
