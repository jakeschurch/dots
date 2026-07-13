{ lib, pkgs, config, ... }:
{
  # Local pull-through Nix binary cache proxy
  services.ncps = {
    enable = true;
    cache = {
      hostName = "apollo";
      maxSize = "50G";
      lru.schedule = "0 2 * * *";
      upstream = {
        urls = [
          "https://cache.nixos.org"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://cache.numtide.com"
        ];
        publicKeys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
    };
    server.addr = "127.0.0.1:8501";
  };

  # Prefer local ncps pull-through cache, but keep upstreams as fallback so a
  # flaky/corrupt/down ncps (invalid nar hash, pod restart, dropped port-forward)
  # can't wedge the whole machine — nix disables 8501 60s and falls through.
  nix.settings.substituters = lib.mkForce [
    "http://localhost:8501"
    "https://cache.nixos.org"
    "https://cache.garnix.io"
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
    "https://cache.numtide.com"
  ];

  nix.settings.trusted-substituters = lib.mkForce [
    "http://localhost:8501"
    "https://cache.nixos.org"
    "https://cache.garnix.io"
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
    "https://cache.numtide.com"
  ];

  nix.settings.trusted-public-keys = lib.mkForce [
    "apollo:i756C7FtllWIbgQipbcvBE3plUXT3ojFhSWcZOuDyHs="
    "apollo:Sm6SbXlzRtoqALHOJHeuMubOwemP5i2r6XvbmRbGWTA="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];

  # Weekly batch TRIM of host btrfs subvols (/, /nix, /home) so freed SSD
  # blocks return to the FTL. Complements the continuous `discard=async` mount
  # option on the data subvols. NOTE: this does NOT shrink the microvm raw
  # images (/var/lib/microvms/*.img) — those only reclaim when the *guest*
  # issues discard through virtio-blk, which is configured in the vmetal
  # k3s-cluster module (guest-side fstrim), not here.
  services.fstrim.enable = true;

  # Enable automatic BTRFS scrubbing to detect corruption early
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # btrbk = fast LOCAL rollback snapshots on nvme only.
  # Cross-disk backup is handled by restic → /mnt/snapshots-backup (see below).
  services.btrbk = {
    instances.btrbk = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "2h";
        snapshot_preserve = "24h 7d 4w 3m";
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

  # ── Desktop-interactivity I/O fairness ────────────────────────────────────
  # Symptom: typing in the Hyprland session froze for seconds when the storage
  # microVMs (mayastor io-engine, worker-1/2/3) hammered the shared 990 PRO.
  # Root cause is btrfs commit stalls under near-full metadata; this stops the
  # *fairness* half — the bulk writers no longer starve desktop fsyncs.
  #
  # blk-iocost (NOT bfq): bfq would collapse the 990 PRO's blk-mq parallelism
  # (16 hw queues, ~1M IOPS) and cripple mayastor rebuild bandwidth. iocost
  # keeps mq + does proportional io.weight fairness. Weights: user.slice (500)
  # ≫ system.slice default (100) ≫ microvm-storage.slice (20, workers only).
  # k3s-server-* stay at default weight — etcd fsync latency must not be
  # throttled (see the leader-election-storm history in cluster.nix).
  systemd.slices.microvm-storage = {
    description = "Bulk-storage microVMs (mayastor io-engine) — deprioritised host I/O";
    sliceConfig = {
      IOWeight = 20;
      StartupIOWeight = 20;
    };
  };

  systemd.slices.user.sliceConfig.IOWeight = 500;

  # Enable blk-iocost on nvme0n1 (259:0). Fixed linear cost model seeded with
  # CONSERVATIVE sustained figures for the 990 PRO 4TB (deliberately below the
  # marketing QD32 peaks so iocost doesn't under-throttle), plus auto vrate
  # control targeting p95 latency. Refine the model under real load with
  # `iocost_monitor.py` if fairness is too loose/tight.
  systemd.services.iocost-nvme = {
    description = "Enable blk-iocost QoS on nvme0n1";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "iocost-nvme" ''
        set -eu
        dev=259:0
        # NB: io.cost.model has no `enable` token (that lives in io.cost.qos);
        # newer kernels (7.x) EINVAL on it. `enable=1` in the qos write below
        # is what actually turns iocost on.
        echo "$dev ctrl=user model=linear \
          rbps=6000000000 rseqiops=900000 rrandiops=750000 \
          wbps=5500000000 wseqiops=850000 wrandiops=700000" \
          > /sys/fs/cgroup/io.cost.model
        echo "$dev enable=1 ctrl=auto rpct=95.00 rlat=2500 wpct=95.00 wlat=2500 min=1.00 max=10000.00" \
          > /sys/fs/cgroup/io.cost.qos
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
