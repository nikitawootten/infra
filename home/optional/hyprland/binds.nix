{ mods, ... }:
''
  bind = ${mods.focus}, Return, exec,kitty
  bind = ${mods.focus}, d, exec,wofi -S drun
  bind = ${mods.window}, q, killactive
  bind = ${mods.window}, e, exit

  # Screenshots
  bind=,Print,exec,grim
  # bind=SHIFT,Print,exec,grimblast --notify copy active
  # bind=CONTROL,Print,exec,grimblast --notify copy screen
  # bind=SUPER,Print,exec,grimblast --notify copy window
  # bind=ALT,Print,exec,grimblast --notify copy area

  # Keyboard controls (brightness, media, sound, etc)
  bind=,XF86MonBrightnessUp,exec,light -A 10
  bind=,XF86MonBrightnessDown,exec,light -U 10

  bind=,XF86AudioNext,exec,playerctl next
  bind=,XF86AudioPrev,exec,playerctl previous
  bind=,XF86AudioPlay,exec,playerctl play-pause
  bind=,XF86AudioStop,exec,playerctl stop
  bind=ALT,XF86AudioNext,exec,playerctld shift
  bind=ALT,XF86AudioPrev,exec,playerctld unshift
  bind=ALT,XF86AudioPlay,exec,systemctl --user restart playerctld

  bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
  bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
  bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle

  bind=SHIFT,XF86AudioMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
  bind=,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
''