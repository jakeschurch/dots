# Disk layout for Samsung SSD 980 PRO 2TB (~1.82 TiB) on /dev/nvme0n1
# VM storage uses ext4 to isolate from BTRFS — prevents unbootable system on hard poweroff
# Snapshot archive uses a separate BTRFS partition so it can't starve root FS free space
{ ... }:
{
  # coldvg holds no host filesystem (LVs are passed raw into worker VMs), so
  # nothing else pulls LVM in. Enable it explicitly: lvm2 + udev autoactivation
  # (pvscan --cache -aay) so /dev/coldvg/cold-wN exists at boot before
  # microvm@k3s-worker-N tries to open the passthrough device.
  services.lvm.enable = true;

  # ===========================================================================
  # MOCK (foundrybox-6j1j): 8TB cold-tier HDD — LVM VG, block-passthrough.
  #
  # One PV over the whole 8TB → VG `coldvg` → 3 logical volumes (one per artemis
  # storage worker). Each LV is a BLOCK DEVICE passed straight into a worker
  # microVM as virtio-blk (see cluster.nix coldStorageDevice) — NOT an img-file.
  # The guest mounts it (fs made once by hand on the host LV) and openebs
  # localpv-hostpath serves Garage's cold DATA tier. Garage metadata (LMDB, hot)
  # stays on mayastor/NVMe — never on this HDD.
  #
  # Why LVM VG (not fixed raw partitions): GROWABLE without repo/partition churn.
  # Add a cold spindle later = `vgextend coldvg <new-pv>` + `lvextend` the LVs +
  # in-guest `xfs_growfs` — the LV device paths (/dev/coldvg/cold-wN) are
  # unchanged, so cluster.nix / vm-hardware passthrough / garage layout stay put.
  # Still pure block passthrough (an LV is a block device): no fs-on-fs, and the
  # sparse-img-fills-/var/lib/microvms footgun that took every VM emergency_ro on
  # 2026-06-25 stays dead. A DiskPool-per-disk / partition-per-worker design
  # would need a new CR + partition + format for every drive added; this doesn't.
  #
  # Device seated 2026-07-09: WDC WD80EFPX-68C4ZN0 (7.28 TiB), by-id below.
  #   Do NOT use /dev/sdX (unstable across reboots).
  # NOTE: one physical HDD on one host = capacity, NOT redundancy. 3 Garage
  #   replicas across these LVs survive a worker-VM roll/OOM (quorum), but NOT
  #   disk/host failure. Cross-host cold redundancy = add an apollo HDD later and
  #   let Garage replicate cold data across artemis+apollo.
  # ===========================================================================
  disko.devices.disk.cold-hdd = {
    type = "disk";
    device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-1F04BDMU";
    content = {
      type = "gpt";
      partitions.pv = {
        size = "100%";
        content = {
          type = "lvm_pv";
          vg = "coldvg";
        };
      };
    };
  };

  # VG spanning the cold spindle(s). Extend across drives with `vgextend coldvg
  # <pv>` (then grow the LVs) — no change here needed to add capacity.
  disko.devices.lvm_vg.coldvg = {
    type = "lvm_vg";
    lvs = {
      # One LV per storage worker. No `content` filesystem: the guest that
      # receives the passed-through LV owns the fs (xfs). LV device paths
      # /dev/coldvg/cold-wN are stable (referenced from cluster.nix).
      cold-w4.size = "2600G";
      cold-w5.size = "2600G";
      cold-w6.size = "100%FREE";
    };
  };

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
