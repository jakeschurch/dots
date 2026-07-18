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
