{ darwin, specialArgs }: {
  persephone = darwin.lib.darwinSystem {
    modules = [ ./persephone ];
    inherit specialArgs;
  };
}
