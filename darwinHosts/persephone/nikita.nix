{ self, lib, config, pkgs, keys, ... }: {
  imports = [ self.homeModules.personal ];

  personal.vscode.enable = true;
  personal.cluster-admin.enable = true;

  home.stateVersion = "23.11";

  personal.git.signingKey = keys.nikita_persephone;
}
