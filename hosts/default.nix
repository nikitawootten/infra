{ lib, specialArgs, homeConfigs }:
lib.mkHosts {
  inherit specialArgs homeConfigs;
  configBasePath = ./.;
  hosts = {
    hades = {
      # My home server
      username = "nikita";
      system = "x86_64-linux";
    };
    olympus = {
      # Old server, unused currently
      username = "nikita";
      system = "x86_64-linux";
    };
    voyager = {
      # My laptop and main development machine
      username = "nikita";
      system = "x86_64-linux";
    };
    dionysus = {
      # My desktop
      username = "nikita";
      system = "x86_64-linux";
    };
    cochrane = {
      # My GPD Pocket 2 mini-laptop
      username = "nikita";
      system = "x86_64-linux";
    };
    raspberrypi4 = {
      # Generic Raspberry Pi 4 (bootstrap config)
      username = "pi";
      system = "aarch64-linux";
    };
    iris = {
      # My Raspberry Pi 4
      username = "nikita";
      system = "aarch64-linux";
    };
  };
}
