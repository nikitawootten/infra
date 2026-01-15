{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.personal.roles.work;
in
{
  options.personal.roles.work = {
    enable = lib.mkEnableOption "Work related software and configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        awscli2
        claude-code
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

    personal.cluster-admin.enable = lib.mkDefault true;
    personal.vscode.enable = lib.mkDefault true;
    personal.firefox.enable = lib.mkDefault true;
  };
}
