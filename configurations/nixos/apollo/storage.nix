{ lib, pkgs, ... }:
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

  # Override substituters to use local ncps pull-through cache
  nix.settings.substituters = lib.mkForce [
    "http://localhost:8501"
  ];

  nix.settings.trusted-substituters = lib.mkForce [
    "http://localhost:8501"
  ];

  nix.settings.trusted-public-keys = lib.mkForce [
    "apollo:i756C7FtllWIbgQipbcvBE3plUXT3ojFhSWcZOuDyHs="
    "apollo:Sm6SbXlzRtoqALHOJHeuMubOwemP5i2r6XvbmRbGWTA="
  ];

  # Enable automatic BTRFS scrubbing to detect corruption early
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # btrbk requires the target directory to exist before send/receive
  systemd.tmpfiles.rules = [
    "d /mnt/snapshots-backup/btrbk 0700 root root -"
  ];

  services.btrbk = {
    instances.btrbk = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "2h";
        snapshot_preserve = "24h 7d 4w 3m";
        target_preserve_min = "no";
        target_preserve = "24h 14d 8w 6m";
        volume."/" = {
          snapshot_dir = "/.snapshots";
          target = "/mnt/snapshots-backup/btrbk";
          subvolume = {
            "/home" = { };
            "/home/jake" = { };
          };
        };
      };
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
