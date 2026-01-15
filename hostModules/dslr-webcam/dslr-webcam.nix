# The following articles were used as guides for this module:
#   - https://www.crackedthecode.co/how-to-use-your-dslr-as-a-webcam-in-linux/
#   - https://www.tomoliver.net/posts/using-an-slr-as-a-webcam-nixos
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dslr-webcam;
in
{
  options.dslr-webcam = {
    enable = lib.mkEnableOption "DSLR webcam";
    virtual-device-name = lib.mkOption {
      type = lib.types.str;
      description = "The name that the camera will show up as";
      default = "Virtual Camera";
    };
    # Unfortunately PRODUCT is the only udev property that is present for both the camera connecting and disconnecting
    camera-udev-product = lib.mkOption {
      type = lib.types.str;
      description = "The PRODUCT of the camera (can be determined by running 'udevadm monitor --property | grep PRODUCT' and pluggin the camera in)";
    };
    ffmpeg-hwaccel = lib.mkOption {
      type = lib.types.bool;
      description = "If enabled, nvdec hwaccel will be used";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gphoto2
      ffmpeg-full
      v4l-utils
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];

    boot.kernelModules = [ "v4l2loopback" ];

    boot.extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 max_buffers=2 card_label="${cfg.virtual-device-name}"
    '';

    services.udev.extraRules = ''
      ACTION=="add", \
      SUBSYSTEM=="usb", \
      ENV{PRODUCT}=="${cfg.camera-udev-product}" \
      RUN+="${pkgs.systemd}/bin/systemctl start dslr-webcam.service"

      ACTION=="remove", \
      SUBSYSTEM=="usb", \
      ENV{PRODUCT}=="${cfg.camera-udev-product}" \
      RUN+="${pkgs.systemd}/bin/systemctl stop dslr-webcam.service"
    '';

    systemd.services.dslr-webcam = {
      script = ''
        # get virtual video device path
        VCAM_DEV=$(${pkgs.v4l-utils}/bin/v4l2-ctl --list-devices | grep -A1 "${cfg.virtual-device-name}" | tail -n 1 | xargs)

        ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie | \
          ${pkgs.ffmpeg-full}/bin/ffmpeg ${lib.strings.optionalString cfg.ffmpeg-hwaccel "-hwaccel nvdec -c:v mjpeg_cuvid"} \
            -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 $VCAM_DEV
      '';
    };
  };
}
