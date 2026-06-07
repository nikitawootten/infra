{ self, ... }:
{
  flake.darwinModules.shortcat =
    { ... }:
    {
      imports = [ self.darwinModules.networking-hosts ];

      homebrew.casks = [ "shortcat" ];

      # Block Shortcat's Sentry error-reporting/telemetry endpoint.
      networking.hosts = {
        "127.0.0.1" = [
          "sentry.shortcat.app"
          "ph.shortcat.app"
        ];
      };
    };
}
