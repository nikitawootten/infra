{ ... }:
{
  flake.homeModules.niri-window-rules = {
    wayland.windowManager.niri.settings._children = [
      {
        window-rule = {
          geometry-corner-radius = [
            8.0
            8.0
            8.0
            8.0
          ];
          clip-to-geometry = true;
        };
      }
      {
        window-rule = {
          _children = [ { match._props.is-active = false; } ];
          opacity = 0.95;
        };
      }
      {
        window-rule = {
          _children = [
            { match._props.title = "floatme"; }
            { match._props.title = "Authentication Required"; }
          ];
          open-floating = true;
        };
      }
      {
        window-rule = {
          _children = [
            {
              match._props = {
                app-id = "firefox";
                title = "Picture-in-Picture";
              };
            }
          ];
          open-floating = true;
          default-floating-position._props = {
            x = 32;
            y = 32;
            relative-to = "bottom-right";
          };
          default-column-width.fixed = 480;
          default-window-height.fixed = 270;
        };
      }
      {
        window-rule = {
          _children = [
            {
              match._props = {
                app-id = "steam";
                title = "^notificationtoasts_\\d+_desktop$";
              };
            }
          ];
          default-floating-position._props = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
          open-focused = false;
        };
      }
      {
        window-rule = {
          _children = [ { match._props.app-id = "dev.noctalia.Noctalia"; } ];
          open-floating = true;
        };
      }
      {
        layer-rule = {
          _children = [ { match._props.namespace = "^noctalia-backdrop"; } ];
          place-within-backdrop = true;
        };
      }
    ];
  };
}
