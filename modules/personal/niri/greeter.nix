{ inputs, ... }:
{
  flake.nixosModules.niri-greeter =
    { config, lib, ... }:
    {
      imports = [ inputs.noctalia-greeter.nixosModules.default ];

      options.personal.niri.greeterSettings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = ''
          Host-specific `greeter.toml` settings, merged over the defaults.
          Mainly `output.{layout,scales,transforms}`: the greeter's bundled
          wlroots compositor does not pick up the kernel `panel_orientation`
          quirk that niri honours, so rotated panels must be spelled out.
        '';
      };

      config.programs.noctalia-greeter = {
        enable = true;
        settings = lib.recursiveUpdate {
          session.default = "Niri";
          user.default = config.personal.user.name;
          appearance = {
            scheme = "Tokyo-Night";
            theme_mode = "dark";
            password_style = "random";
          };
          keyboard = {
            layout = "us,ru";
            options = "grp:win_space_toggle,caps:escape";
          };
          cursor = {
            theme = "Adwaita";
            size = 24;
          };
        } config.personal.niri.greeterSettings;
      };
    };
}
