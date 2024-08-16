{ pkgs, inputs, ... }: {
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = {
    stylix = {
      fonts = {
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
      };
    };
  };
}
