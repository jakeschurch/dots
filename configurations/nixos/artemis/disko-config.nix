# Disk layout for Samsung SSD 980 PRO 2TB (~1.82 TiB) on /dev/nvme0n1
# VM storage uses ext4 to isolate from BTRFS — prevents unbootable system on hard poweroff
# Snapshot archive uses a separate BTRFS partition so it can't starve root FS free space
{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S6B0NL0TC03605L_1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            extraArgs = [
              "-n"
              "EFI"
              "-F"
              "32"
            ];
          };
        };
        swap = {
          size = "32G";
          content = {
            type = "swap";
          };
        };
        vms = {
          size = "500G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var/lib/microvms";
            extraArgs = [
              "-L"
              "microvms"
            ];
          };
        };
        snapshots = {
          size = "150G";
          content = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/snapshots-archive";
            extraArgs = [
              "-L"
              "snapshots-archive"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-f"
              "-m"
              "dup"
              "-d"
              "single"
            ];
            mountpoint = "/partition-root";
            subvolumes = {
              "/" = {
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                  "space_cache=v2"
                  "commit=30"
                ];
              };
              "/var/log" = {
                mountOptions = [
                  "noatime"
                  "discard=async"
                  "space_cache=v2"
                ];
              };
              "/.snapshots" = {
                mountOptions = [
                  "noatime"
                  "space_cache=v2"
                ];
              };
              "/home" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "space_cache=v2"
                ];
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
              };
            };
          };
        };
      };
    };
  };
}
