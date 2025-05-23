{ config, lib, self, inputs, secrets, keys, ... }: {
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  system.primaryUser = lib.mkDefault "nikita";

  users.users.${config.system.primaryUser} = {
    name = config.system.primaryUser;
    home = "/Users/${config.system.primaryUser}";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit self inputs secrets keys; };
    users.${config.system.primaryUser} = { };
    sharedModules = [{
      home.stateVersion = "24.11";
      imports = [ self.homeModules.personal ];
    }];
  };
}
