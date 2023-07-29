{ mods, ... }:
let


  # Shorthand for directional commands
  udlr = mod: directive: optionalPrefix: 
  let
    prefix = (if optionalPrefix == null then "" else optionalPrefix + ":");
  in
  ''
    bind = ${mod}, left, ${directive}, ${prefix}l
    bind = ${mod}, right, ${directive}, ${prefix}r
    bind = ${mod}, up, ${directive}, ${prefix}u
    bind = ${mod}, down, ${directive}, ${prefix}d
    bind = ${mod}, h, ${directive}, ${prefix}l
    bind = ${mod}, l, ${directive}, ${prefix}r
    bind = ${mod}, k, ${directive}, ${prefix}u
    bind = ${mod}, j, ${directive}, ${prefix}d
  '';

  # Shorthand for workspace movement commands
  eachWorkspace = mod: directive: ''
    bind = ${mod}, 1, ${directive}, 1
    bind = ${mod}, 2, ${directive}, 2
    bind = ${mod}, 3, ${directive}, 3
    bind = ${mod}, 4, ${directive}, 4
    bind = ${mod}, 5, ${directive}, 5
    bind = ${mod}, 6, ${directive}, 6
    bind = ${mod}, 7, ${directive}, 7
    bind = ${mod}, 8, ${directive}, 8
    bind = ${mod}, 9, ${directive}, 9
    bind = ${mod}, 0, ${directive}, 10
  '';
in
''
  # Scroll through existing workspaces with ${mods.focus} + scroll
  bind = ${mods.focus}, mouse_down, workspace, e+1
  bind = ${mods.focus}, mouse_up, workspace, e-1

  # Move/resize windows with ${mods.focus} + LMB/RMB and dragging
  bindm = ${mods.focus}, mouse:272, movewindow
  bindm = ${mods.focus}, mouse:273, resizewindow

  # Focus windows with ${mods.focus} + Up/Down/Left/Right/H/J/K/L
  ${udlr mods.focus "movefocus" null}

  # Move windows with ${mods.window} + Up/Down/Left/Right/H/J/K/L
  ${udlr mods.window "movewindow" null}

  # Move monitors with ${mods.monitor} + Up/Down/Left/Right/H/J/K/L
  ${udlr mods.monitor "movewindow" "mon"}

  # Switch workspaces with ${mods.focus} + [0-9]
  ${eachWorkspace mods.focus "workspace"}

  # Move active window to a workspace with ${mods.focus} + SHIFT + [0-9]
  ${eachWorkspace mods.window "movetoworkspace"}
''