{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.personal.cluster-admin;
in
{
  options.personal.cluster-admin = {
    enable = lib.mkEnableOption "Enable kubernetes admin tools";
  };

  config = lib.mkIf cfg.enable (
    let
      helm-with-plugins = (
        pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = with pkgs.kubernetes-helmPlugins; [
            helm-secrets
            helm-diff
            helm-s3
            helm-git
          ];
        }
      );
      helmfile-with-plugins = pkgs.helmfile-wrapped.override {
        inherit (helm-with-plugins) pluginsDir;
      };
    in
    {
      programs.k9s.enable = true;

      home.packages = with pkgs; [
        kubectl
        kubectx
        helm-with-plugins
        helmfile-with-plugins
        helm-ls
      ];

      programs.starship.settings.kubernetes.disabled = false;
    }
  );
}
