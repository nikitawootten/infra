{
  self,
  inputs,
  lib,
  config,
  pkgs,
  secrets,
  keys,
  ...
}:
let
  cfg = config.personal.user;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.personal.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "nikita";
      description = "Username to set up with home-manager";
    };
  };

  config = {
    users.groups.media = { };
    users.users.${cfg.name} = {
      # Default user should have UID of 1000 for consistency
      uid = lib.mkDefault 1000;
      extraGroups = [
        "wheel"
        "media"
        "tty"
        "video"
      ];
      shell = lib.mkForce pkgs.zsh;
      description = lib.mkDefault "Nikita";
      isNormalUser = lib.mkDefault true;
      initialHashedPassword = "$y$j9T$3DxK1nrBp3Xl2DHN8X97y0$19IRZEIoDdq.owYAW9MFataPDunzsyfWXS25aT3Am77";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit
          self
          inputs
          secrets
          keys
          ;
      };
      users.${config.personal.user.name} = { };
      sharedModules = [
        {
          home.stateVersion = config.system.stateVersion;
          imports = [ self.homeModules.personal ];
        }
      ];
    };
  };
}
