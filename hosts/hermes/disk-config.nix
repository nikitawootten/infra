{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "4G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              end = "-12G";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
              };
            };
            encryptedSwap = {
              size = "6G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority =
                  100; # prefer to encrypt as long as we have space for it
              };
            };
            plainSwap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hibernation from this device
              };
            };
          };
        };
      };
    };
  };
}
