{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "5G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                extraArgs = [
                  "-nEFI"
                  "-F32"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                mountpoint = "/partition-root";
                type = "btrfs";
                extraArgs = [ "-f" ];
                swap = {
                  swapfile = {
                    size = "20G";
                  };
                };
                subvolumes = {
                  "/" = {
                    mountpoint = "/";
                  };
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "noatime"
                      "nodiscard"
                    ];
                  };
                  "/home" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/home";
                  };
                  "/home/jake" = { };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "nodiscard"
                    ];
                    mountpoint = "/nix";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "20M";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
