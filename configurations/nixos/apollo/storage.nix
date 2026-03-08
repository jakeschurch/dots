{ lib, ... }:
{
  # Local pull-through Nix binary cache proxy
  services.ncps = {
    enable = true;
    cache = {
      hostName = "apollo";
      maxSize = "50G";
      lru.schedule = "0 2 * * *";
    };
    server.addr = "127.0.0.1:8501";
    upstream = {
      caches = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
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
  ];

  # Enable automatic BTRFS scrubbing to detect corruption early
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.btrbk = {
    instances.btrbk = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "1d";
        snapshot_preserve = "7d 4w";
        volume."/" = {
          snapshot_dir = "/.snapshots";
          subvolume = {
            "/" = { };
            "/home" = { };
            "/home/jake" = { };
          };
        };
      };
    };
  };
}
