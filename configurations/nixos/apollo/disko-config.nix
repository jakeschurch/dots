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
      # SNAPSHOTS / restic-backup disk (btrfs) — the PNY CS1311 120G. Pinned by
      # by-id: the raw /dev/sdb letter is UNSAFE. The kernel reassigned sd
      # letters (2026-07-09 the reclaimed 860 EVO became /dev/sdb), so /dev/sdb
      # now resolves to the MAYASTOR disk, not this one — a disko format on the
      # old path would btrfs-wipe the mayastor pool. by-id keeps this pointed at
      # the real PNY (snapshots data untouched). Attr name kept as "sdb".
      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-PNY_CS1311_120GB_SSD_PNY36162191600105DAB";
        content = {
          type = "gpt";
          partitions = {
            snapshots-metadata = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/mnt/snapshots-backup";
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                  "space_cache=v2"
                  "nofail"
                ];
                extraArgs = [
                  "-L"
                  "snapshots-metadata"
                ];
              };
            };
          };
        };
      };
      # Reclaimed Samsung 860 EVO (931G, was a dead Proxmox pve VG) → one LVM PV
      # for the apollovg warm-mayastor pool. by-id, immune to sd-letter swaps.
      mayastor = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S4FMNE0M906739Z";
        content = {
          type = "gpt";
          partitions.apollopv = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "apollovg";
            };
          };
        };
      };
    };
    # Warm mayastor pool on the 860 EVO (foundrybox-6j1j). One RAW LV — no
    # content/filesystem: it's passed through to k3s-worker-1 as virtio-blk and
    # mayastor owns the block device (SPDK lvstore) + formats it itself. Grow
    # later without repo churn: vgextend apollovg <new-pv> + lvextend.
    lvm_vg.apollovg = {
      type = "lvm_vg";
      lvs.mayastor-w1 = {
        size = "100%FREE";
      };
    };
  };
  # apollovg holds no host filesystem (the LV is passed raw into worker-1), so
  # nothing else pulls LVM in. Enable it so udev autoactivates apollovg at boot
  # before microvm@k3s-worker-1 opens the passthrough device.
  services.lvm.enable = true;
}
