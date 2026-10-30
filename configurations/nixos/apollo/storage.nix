{
  lib,
  pkgs,
  config,
  ...
}:
let
  cachesData = import ../../../modules/data/caches.nix;
  apolloCaches = cachesData.defaultFor "linux";
in
{
  nix.settings.substituters = lib.mkForce (cachesData.urls apolloCaches);
  nix.settings.trusted-substituters = lib.mkForce (cachesData.urls apolloCaches);
  nix.settings.trusted-public-keys = lib.mkForce (cachesData.keys apolloCaches);

  # Weekly batch TRIM of host btrfs subvols (/, /nix, /home) so freed SSD
  # blocks return to the FTL. This is now the SOLE TRIM path: the continuous
  # `discard=async` mount option was dropped from disko-config.nix because it
  # fed freed extents into the btrfs commit path and, under nix-gc + snapshot
  # churn, stretched commits to 250s+ (blocking journald past its watchdog).
  # Batch fstrim keeps trims off the commit critical path. NOTE: this does NOT
  # shrink the microvm raw images (/var/lib/microvms/*.img) — those only reclaim
  # when the *guest* issues discard through virtio-blk, configured in the vmetal
  # k3s-cluster module (guest-side fstrim), not here.
  services.fstrim.enable = true;

  # Backstop for btrfs commit stalls: if a transaction commit ever overruns
  # again, journald's fsync/ftruncate can block for minutes. The default 3min
  # service watchdog then SIGABRTs journald, dumping a core and losing the log
  # window — the collateral damage that produced 138 coredumps here. Raising the
  # watchdog to 6min lets journald ride out a slow commit instead of aborting.
  # This does NOT fix commit latency (the discard=async removal above does) —
  # it only stops the crash-on-stall feedback loop. Watch `max_commit_ms` in
  # /sys/fs/btrfs/<uuid>/commit_stats to confirm commits stay low.
  systemd.services.systemd-journald.serviceConfig.WatchdogSec = "6min";

  # Disabled after another 990 PRO controller failure during the 2026-10-14
  # scrub, despite the 300M/s limit. The APST workaround in boot.nix first
  # became active after that failure; its effectiveness is still unproven.
  # Keep the schedule and limit for a future supervised re-enable.
  services.btrfs.autoScrub = {
    enable = false;
    interval = "Wed *-*-* 03:30:00";
    limit = "300M";
    fileSystems = [ "/" ];
  };

  # btrbk = fast LOCAL rollback snapshots on nvme only.
  # Cross-disk backup is handled by restic → /mnt/snapshots-backup (see below).
  services.btrbk = {
    instances.btrbk = {
      onCalendar = "0/5:00";
      settings = {
        snapshot_preserve_min = "5h";
        snapshot_preserve = "48h 7d 4w 3m";
        volume."/" = {
          snapshot_dir = "/.snapshots";
          subvolume = {
            "/home/jake" = { };
          };
        };
      };
    };
  };

  # Cross-disk backup: file-level, deduplicated, compressed, encrypted.
  # Backs up /home/jake to sdb, excluding regenerable/large caches so the
  # precious set (~40-60 GiB) fits the 112 GiB disk with room to spare.
  sops.secrets."restic-home-password" = {
    sopsFile = ../../../secrets/restic.yaml;
    owner = "root";
    mode = "0400";
  };

  services.restic.backups.home = {
    repository = "/mnt/snapshots-backup/restic";
    passwordFile = config.sops.secrets."restic-home-password".path;
    initialize = true;
    paths = [ "/home/jake" ];
    exclude = [
      "/home/jake/.cache"
      "/home/jake/.local/share/Steam"
      "/home/jake/.local/share/comfyui"
      "/home/jake/.npm"
      "/home/jake/.local/share/pnpm"
      "/home/jake/go/pkg"
      "/home/jake/.config/google-chrome*"
      "**/node_modules"
      "**/_build"
      "**/target"
      "**/.direnv"
      "**/result"
      "**/result-*"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 6"
    ];
  };

  # restic shares nvme0n1 with the k3s server images (etcd WAL). kyber ignores
  # IOSchedulingClass, so the bandwidth/IOPS caps (blk-throttle) and IOWeight
  # (iocost, below) are what actually bound it; CPU idle/nice also apply.
  systemd.services.restic-backups-home.serviceConfig = {
    Nice = 19;
    CPUSchedulingPolicy = "idle";
    IOSchedulingClass = "idle";
    IOWeight = 10;
    IOReadBandwidthMax = "/dev/nvme0n1 100M";
    IOReadIOPSMax = "/dev/nvme0n1 2000";
    IOWriteBandwidthMax = "/dev/nvme0n1 50M";
  };

  # blk-iocost on nvme0n1 (259:0) so cgroup IOWeight is honoured under kyber
  # (bfq would collapse blk-mq parallelism; see 1ba042^ for the original).
  # vrate floor min=25 keeps a saturated device from throttling everyone to 1%.
  # Live off-switch: echo "259:0 enable=0" > /sys/fs/cgroup/io.cost.qos
  systemd.services.iocost-nvme = {
    description = "Enable blk-iocost QoS on nvme0n1";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "iocost-nvme" ''
        set -eu
        dev=$(cat /sys/block/nvme0n1/dev)
        echo "$dev ctrl=user model=linear \
          rbps=6000000000 rseqiops=900000 rrandiops=750000 \
          wbps=5500000000 wseqiops=850000 wrandiops=700000" \
          > /sys/fs/cgroup/io.cost.model
        echo "$dev enable=1 ctrl=user rpct=95.00 rlat=5000 wpct=95.00 wlat=5000 min=25.00 max=10000.00" \
          > /sys/fs/cgroup/io.cost.qos
      '';
      ExecStop = pkgs.writeShellScript "iocost-nvme-off" ''
        echo "$(cat /sys/block/nvme0n1/dev) enable=0" > /sys/fs/cgroup/io.cost.qos
      '';
    };
  };

  # Monthly balance to consolidate sparse chunks; idle I/O so it doesn't interfere
  systemd.services.btrfs-balance = {
    description = "Btrfs balance";
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=85 -musage=85 /";
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
      Nice = 19;
    };
  };

  systemd.timers.btrfs-balance = {
    description = "Monthly Btrfs balance";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
