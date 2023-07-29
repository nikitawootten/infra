{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libnotify # for notify-send
    wl-clipboard
    grim # screenshots
    wl-mirror # screen mirroring
    wf-recorder # screen recording
    slurp # grab selection (for use in grim and wf-recorder)
    light # control backlight
    pulseaudio # for pactl
    playerctl
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  services.playerctld.enable = true;

  programs.kitty = {
    enable = true;
  };

  services.mako = {
    enable = true;
  };

  programs.wofi = {
    enable = true;
  };
}