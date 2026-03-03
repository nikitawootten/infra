{ self, inputs, ... }:
let
  hmModule =
    { pkgs, lib, ... }:
    {
      imports = [
        self.modules.homeManager.cluster-admin
        self.modules.homeManager.firefox
      ];

      home.packages =
        with pkgs;
        [
          awscli2
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
          basedpyright
          rustup
          nixd
          vscode-json-languageserver
          nodejs_24
          scrcpy
        ]
        ++ (lib.lists.optionals pkgs.stdenv.isLinux [ httpie-desktop ])
        ++ (lib.lists.optionals pkgs.stdenv.isDarwin [
          swiftlint
          xcbeautify
          swift-format
        ]);
    };
in
{
  flake.modules.homeManager.role-work = hmModule;

  flake.modules.nixos.role-work =
    { pkgs, config, ... }:
    {
      imports = [
        self.modules.nixos.docker
        self.modules.nixos.printing
        self.modules.nixos.flatpak
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

      services.flatpak.packages = [ "com.slack.Slack" ];
    };

  flake.modules.darwin.role-work =
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
