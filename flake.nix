{
  description = "Nikita's Nix-ified setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, devenv, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      customPackages = import ./packages { inherit nixpkgs; };
      overlays = [ customPackages.overlay ];
      commonInherits = {
        inherit nixpkgs nixpkgs-unstable home-manager devenv overlays;
      };
    in
    {
      nixosConfigurations = import ./hosts commonInherits;
      homeConfigurations = import ./home commonInherits;

      overlays.default = customPackages.overlay;
      packages = customPackages.packages;

      devShells = nixpkgs.lib.genAttrs
        systems
        (system: {
          default = import ./shell.nix { pkgs = import nixpkgs { inherit system overlays; }; };
        });
    };
}
