{ lib, specialArgs }:
lib.mkHomes {
  inherit specialArgs;
  configBasePath = ./.;
  defaultModules = [
    ({ inputs, self, ... }: {
      imports = [
        self.homeModules.personal
        inputs.nix-index-database.hmModules.nix-index
      ];
    })
  ];
  homes = {
    nikita.system = "x86_64-linux";
    "nikita@voyager".system = "x86_64-linux";
    "nikita@dionysus".system = "x86_64-linux";
    "nikita@hades".system = "x86_64-linux";
    "nikita@olympus".system = "x86_64-linux";
    "nikita@cochrane".system = "x86_64-linux";
    "pi@raspberrypi4".system = "aarch64-linux";
    "nikita@iris".system = "aarch64-linux";
  };
}
