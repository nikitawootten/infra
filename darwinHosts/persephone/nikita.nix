{ self, keys, ... }: {
  imports = [ self.homeModules.personal ];

  personal.vscode.enable = true;
  personal.cluster-admin.enable = true;
  personal.kitty.enable = true;

  personal.git.signingKey = keys.nikita_persephone;
}
