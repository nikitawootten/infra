{ ... }:
''
  input {
    touchpad {
      natural_scroll = true
    }
  }

  gestures {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = true
  }

  monitor = eDP-1, preferred, auto, 1
  monitor = , preferred, auto, auto
''