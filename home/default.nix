{ nixpkgs, nixpkgs-unstable, home-manager, devenv, overlays, isNixOsModule ? false, ... }@inputs:
let
  # Common modules shared by all configs
  commonModules = [
    ./direnv.nix
    ./editor.nix
    ./fzf.nix
    ./git.nix
    ./shell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
  ];

  # Conditionally generates config compatible with HomeManager flake or as NixOS modules
  mkHome = username: system: extraModules:
    (if isNixOsModule then mkHomeManagerNixOsModule else mkHomeManagerConfig) username system ([
      {
        home =
          let
            homesDir = if (nixpkgs.lib.hasInfix "darwin" system) then "/Users" else "/home";
          in
          {
            inherit username;
            homeDirectory = "${homesDir}/${username}";
            stateVersion = "22.11";

            packages = [
              devenv.packages.${system}.devenv
            ];
          };
        programs.home-manager.enable = true;
        nix = {
          # NixOS overrides this
          package = nixpkgs.lib.mkDefault nixpkgs.legacyPackages.${system}.nixFlakes;
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
        };
      }
    ] ++ commonModules ++ extraModules);

  # Generates config compatible with NixOS modules
  mkHomeManagerNixOsModule = username: system: modules: map
    (module:
      let
        commonInherits = inputs // {
          pkgs = import nixpkgs { inherit system overlays; };
          pkgs-unstable = import nixpkgs-unstable { inherit system; };
          lib = nixpkgs.lib;
          inherit system;
        };
      in
      {
        # Resolve import if path type is passed in
        home-manager.users.${username} = if builtins.isPath module then (import module commonInherits) else module;
      })
    modules;

  # Generates config compatible with HomeManager flake output
  mkHomeManagerConfig = _: system: modules:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system overlays; };
      extraSpecialArgs = {
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        inherit system;
      };
      inherit modules;
    };
in
# TODO instead of generating a nixos module or home-manager configuration
  # depending on the `isNixOsModule` input attr, wrap this configuration in a
  # helper function that generates output attrs `.homeConfigs` and
  # `nixosModules` that can be consumed directly.
{
  # Framework laptop running Arch Linux
  "nikita@yukon" = mkHome "nikita" "x86_64-linux" [
    ./git-signed.nix
  ];
  # Desktop running Fedora (single user Nix install due to SELinux)
  "nikita@defiant" = mkHome "nikita" "x86_64-linux" [
    ./git-signed.nix
  ];
  # Dell Poweredge R610 running NixOS
  # TODO configure SSH-Agent forwarding
  "nikita@danzek" = mkHome "nikita" "x86_64-linux" [ ];

  # Work machine running MacOS
  "naw2@PN118973" = mkHome "naw2" "aarch64-darwin" [{
    programs.git.userEmail = nixpkgs.lib.mkForce "nikita.wootten@nist.gov";
    # output of `eval "$(/opt/homebrew/bin/brew shellenv)"`
    home.sessionVariables = {
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_REPOSITORY = "/opt/homebrew";
      MANPATH = "/opt/homebrew/share/man\${MANPATH+:$MANPATH}:";
      INFOPATH = "/opt/homebrew/share/info:\${INFOPATH:-}";
    };
    home.sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
  }];
}
