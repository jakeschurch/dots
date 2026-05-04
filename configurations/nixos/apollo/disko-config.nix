{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7K6NU0Y613BB5L_1";
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
            swap = {
              size = "128G";
              content = {
                type = "swap";
              };
            };
            root = {
              size = "100%";
              content = {
                mountpoint = "/partition-root";
                type = "btrfs";
                extraArgs = [
                  "-f"
                  # Add metadata duplication for better corruption resistance
                  "-m"
                  "dup"
                  "-d"
                  "single"
                ];
                subvolumes = {
                  "/" = {
                    mountpoint = "/";
                    mountOptions = [
                      # Add these global safety options
                      "noatime"
                      "space_cache=v2"
                      "commit=30" # Commit every 30s instead of default 5s (safer)
                    ];
                  };
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                  "/vms" = {
                    mountpoint = "/var/lib/microvms";
                    mountOptions = [
                      "nodatacow"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                    mountpoint = "/home";
                  };
                  "/home/jake" = {
                    mountpoint = "/home/jake";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                    ];
                  };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                      "space_cache=v2"
                    ];
                    mountpoint = "/nix";
                  };
                  # ADD SNAPSHOTS SUBVOLUME
                  "/.snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                };
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            snapshots-metadata = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                extraArgs = [
                  "-L"
                  "snapshots-metadata"
                ];
              };
            };
          };
        };
      };
    };
  };
}
