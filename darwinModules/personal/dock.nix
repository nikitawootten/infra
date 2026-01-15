{ config, ... }:
{
  system = {
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        orientation = "bottom";
        wvous-tl-corner = 2; # show mission control (gnome parity)
        mru-spaces = false; # don't rearrange my spaces

        persistent-others = [
          config.system.defaults.screencapture.location
          "/Users/nikita/Downloads"
        ];
      };

      screencapture.location = "/Users/nikita/Pictures/Screenshots";
    };
  };
}
