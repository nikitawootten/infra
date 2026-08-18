{ self, inputs, ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    let
      claude-code = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      claude-personal = pkgs.writeShellScriptBin "claude-personal" ''
        export CLAUDE_CONFIG_DIR="$HOME/.claude-personal"
        exec ${claude-code}/bin/claude "$@"
      '';
    in
    {
      imports = [
        self.homeModules.cluster-admin
        self.homeModules.firefox
      ];

      home.packages =
        with pkgs;
        [
          awscli2
          claude-code
          claude-personal
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
          ollama
          basedpyright
          rustup
          nixd
          vscode-json-languageserver
          nodejs_24
          scrcpy
        ]
        ++ (lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
          httpie-desktop
          self.packages.${pkgs.stdenv.hostPlatform.system}.lotion
        ])
        ++ (lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
          swiftlint
          xcbeautify
          swift-format
        ]);
    };
in
{
  flake.homeModules.role-work = hmModule;

  flake.nixosModules.role-work =
    { pkgs, config, ... }:
    {
      imports = [
        self.nixosModules.docker
        self.nixosModules.printing
        self.nixosModules.flatpak
      ];

      home-manager.sharedModules = [ hmModule ];

      # Android development
      users.users.${config.personal.user.name}.extraGroups = [
        "adbusers"
        "kvm"
      ];
      environment.systemPackages = [
        pkgs.android-studio
        pkgs.android-tools
      ];

      services.flatpak.packages = [
        "com.slack.Slack"
        "us.zoom.Zoom"
      ];
    };

  flake.darwinModules.role-work =
    { ... }:
    {
      home-manager.sharedModules = [ hmModule ];

      homebrew.masApps = {
        AppleDeveloper = 640199958;
        TestFlight = 899247664;
      };
      homebrew.brews = [ "xcode-build-server" ];
      homebrew.casks = [
        "figma"
        "google-chrome"
        "notion"
        "slack"
        "zoom"
        "httpie-desktop"
        "sf-symbols"
        "android-studio"
        "android-platform-tools"
        "proxyman"
        "claude"
      ];
    };
}
