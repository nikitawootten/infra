{
  description = "Nikita's Nix-ified setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      overlays = [
        (import ./packages)
      ];
      commonInherits = {
        inherit inputs nixpkgs home-manager self overlays;
      };
    in
    {
      nixosConfigurations = import ./hosts commonInherits;
      homeConfigurations = import ./home commonInherits;

      devShells = nixpkgs.lib.genAttrs
        systems
        (system: {
          default = import ./shell.nix { pkgs = import nixpkgs { inherit system overlays; }; };
        });
    };
}
