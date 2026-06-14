{ inputs, ... }:
{
  flake.nixosModules.base =
    { pkgs, lib, ... }:
    {
      time.timeZone = lib.mkDefault "America/New_York";
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
      };

      programs.zsh.enable = true;

      services.fwupd.enable = lib.mkDefault true;

      environment.systemPackages = with pkgs; [
        gnumake
        wget
        git
        tmux
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      nix = {
        settings = {
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
          # numtide cache serves the llm-agents packages (claude-code, codex,
          # …), which are not on cache.nixos.org. Configured system-wide here
          # rather than in role-work so non-work hosts (e.g. hades, which builds
          # these in CI) also substitute instead of building from source.
          extra-substituters = [ "https://cache.numtide.com" ];
          extra-trusted-public-keys = [
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
        };
        package = pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      };

      nixpkgs.config.allowUnfree = true;

      security.sudo.execWheelOnly = true;

      system.stateVersion = "25.05";
    };
}
