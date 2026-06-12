{ inputs, ... }:
{
  flake.nixosModules.remote-builder-client =
    {
      config,
      pkgs,
      secrets,
      keys,
      ...
    }:
    let
      toBase64 =
        s:
        builtins.readFile (
          pkgs.runCommand "base64-encoded" { } ''
            printf '%s' ${pkgs.lib.escapeShellArg s} | base64 -w0 > $out
          ''
        );
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];

      age.secrets.nix-builder-key.file = secrets.nix-builder-key;

      nix.distributedBuilds = true;
      nix.settings = {
        builders-use-substitutes = true;
        extra-substituters = [ "https://cache.hades.arpa.nikita.computer" ];
        extra-trusted-public-keys = [ keys.hades_cache ];
        connect-timeout = 5;
      };

      nix.buildMachines = [
        {
          hostName = "hades";
          protocol = "ssh-ng";
          sshUser = "nixremote";
          sshKey = config.age.secrets.nix-builder-key.path;
          publicHostKey = toBase64 keys.hades;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          maxJobs = 8;
          speedFactor = 2;
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
            "benchmark"
          ];
        }
      ];
    };

  flake.nixosModules.remote-builder-host =
    { keys, ... }:
    {
      users.users.nixremote = {
        isSystemUser = true;
        description = "Remote nix build user";
        group = "nixremote";
        # The build protocol is exec'd through the login shell, so this can't
        # be nologin; the authorized_keys restrictions below do the lockdown
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          ''restrict,command="/run/current-system/sw/bin/nix-daemon --stdio" ${keys.nixremote}''
        ];
      };
      users.groups.nixremote = { };
      nix.settings.trusted-users = [ "nixremote" ];

      # Builds must not degrade other workloads (i.e. jellyfin)
      nix.daemonCPUSchedPolicy = "idle";
      nix.daemonIOSchedClass = "idle";
      systemd.services.nix-daemon.serviceConfig = {
        MemoryHigh = "70%";
        MemoryMax = "85%";
      };
    };
}
