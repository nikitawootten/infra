{ darwin, specialArgs }: {
  persephone = darwin.lib.darwinSystem {
    modules = [ ./persephone ];
    inherit specialArgs;
  };
  defiant = darwin.lib.darwinSystem {
    modules = [ ./defiant ];
    inherit specialArgs;
  };
}
