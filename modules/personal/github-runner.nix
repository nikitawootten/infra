{ inputs, ... }:
{
  flake.nixosModules.github-runner =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.personal.github-runner;
    in
    {
      options.personal.github-runner = {
        enable = lib.mkEnableOption "a self-hosted, ephemeral GitHub Actions runner";

        url = lib.mkOption {
          type = lib.types.str;
          default = "https://github.com/nikitawootten/infra";
          description = "GitHub repository (or org) URL to register the runner against.";
        };

        tokenFile = lib.mkOption {
          type = lib.types.path;
          description = ''
            File holding a fine-grained PAT (or GitHub App token) with repo
            Administration: read/write. The runner uses it to auto-mint
            short-lived registration tokens, so registration tokens never need
            manual rotation.
          '';
        };

        extraLabels = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            config.networking.hostName
            "nixos"
          ];
          defaultText = lib.literalExpression ''[ config.networking.hostName "nixos" ]'';
          description = "Extra labels applied to the runner for `runs-on` targeting.";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs; [
            nix
            git
            gnumake
            gh
            jq
            openssh
            gnutar
            gzip
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
          ];
          defaultText = lib.literalExpression "see source (nix, git, gnumake, gh, jq, openssh, gnutar, gzip, claude-code)";
          description = "Tools available on PATH to every job.";
        };
      };

      config = lib.mkIf cfg.enable {
        users.users.github-runner = {
          isSystemUser = true;
          group = "github-runner";
          home = "/var/lib/github-runner";
          createHome = true;
        };
        users.groups.github-runner = { };

        nix.settings.trusted-users = [ "github-runner" ];

        services.github-runners.${config.networking.hostName} = {
          enable = true;
          inherit (cfg)
            url
            tokenFile
            extraLabels
            extraPackages
            ;

          # The nixpkgs runner package only ships a node24 external, but actions
          # like actions/checkout@v4 and peter-evans/create-pull-request still
          # declare `using: node20`, so the runner looks for the absent
          # lib/externals/node20/bin/node and fails with a misleading ENOENT.
          # Alias node20 -> node24 in the package so that lookup resolves.
          package = pkgs.github-runner.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              ln -s node24 "$out/lib/externals/node20"
            '';
          });

          ephemeral = true; # one job per instance, then re-register fresh
          replace = true;

          user = "github-runner";
          group = "github-runner";
        };
      };
    };
}
