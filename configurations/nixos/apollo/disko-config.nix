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
              size = "2000G";
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
                # One option set for every subvolume: compress/commit are
                # filesystem-wide on btrfs (first mount wins), so per-subvol
                # variation was cosmetic and misleading. space_cache=v2 dropped
                # (kernel default since 5.15).
                #
                # discard=async removed: it queued freed extents into the commit
                # path, and under this box's delete-heavy load (nix-gc mass store
                # deletes, hourly btrbk snapshot rotation) that inflated btrfs
                # transaction commits to 250s+ — long enough to block journald's
                # fsync/ftruncate past its 3min watchdog (138 coredumps). TRIM is
                # now handled solely by the weekly services.fstrim batch (see
                # storage.nix), which keeps trims out of the commit critical path.
                subvolumes =
                  let
                    btrfsMountOptions = [
                      "compress=zstd"
                      "noatime"
                      "commit=30"
                    ];
                  in
                  {
                    "/" = {
                      mountpoint = "/";
                      mountOptions = btrfsMountOptions;
                    };
                    "/var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfsMountOptions;
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsMountOptions;
                    };
                    "/home/jake" = {
                      mountpoint = "/home/jake";
                      mountOptions = btrfsMountOptions;
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsMountOptions;
                    };
                    "/.snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = btrfsMountOptions;
                    };
                  };
              };
            };
            # VM system images (root overlays, rancher/data disks). xfs: no
            # CoW, no shared-FS commit coupling with the desktop, classic VM
            # image filesystem. microvm.nix auto-creates imgs as plain files.
            vms = {
              size = "750G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/var/lib/microvms";
                mountOptions = [ "noatime" ];
                extraArgs = [ "-L" "microvms" ];
              };
            };
            # Raw mayastor pool for k3s-worker-2 (SPDK owns it, no host fs) —
            # nvme sibling of the 860 EVO apollovg/mayastor-w1 pattern below.
            pool = {
              size = "846G";
              content = {
                type = "lvm_pv";
                vg = "nvmevg";
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
    # Raw mayastor pool for k3s-worker-2 on the nvme tail (p5). Same pattern:
    # no content/filesystem — passed through as virtio-blk, SPDK formats it.
    lvm_vg.nvmevg = {
      type = "lvm_vg";
      lvs.mayastor-w2 = {
        size = "100%FREE";
      };
    };
  };
  # apollovg holds no host filesystem (the LV is passed raw into worker-1), so
  # nothing else pulls LVM in. Enable it so udev autoactivates apollovg at boot
  # before microvm@k3s-worker-1 opens the passthrough device.
  services.lvm.enable = true;
}
