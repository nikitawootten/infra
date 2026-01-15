{ nixpkgs, specialArgs }:
{
  hades = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit specialArgs;
    modules = [ ./hades ];
  };
  voyager = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = specialArgs;
    modules = [ ./voyager ];
  };
  dionysus = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit specialArgs;
    modules = [ ./dionysus ];
  };
  cochrane = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit specialArgs;
    modules = [ ./cochrane ];
  };
  iris = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    inherit specialArgs;
    modules = [ ./iris ];
  };
  hermes = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    inherit specialArgs;
    modules = [ ./hermes ];
  };
}
