{
  pkgs,
  lib,
  config,
  ...
}:
let
  dataDir = "/var/lib/ncps";
  addr = "127.0.0.1:8501";

  configFile = pkgs.writeText "ncps-config.json" (
    builtins.toJSON {
      log.level = "info";
      server.addr = addr;
      cache = {
        hostname = config.networking.hostName;
        "max-size" = "50G";
        "sign-narinfo" = false; # pass through upstream signatures; no local key needed
        "database-url" = "sqlite:${dataDir}/db/db.sqlite";
        storage.local = dataDir;
        lru.schedule = "0 2 * * *";
        upstream = {
          urls = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://hyprland.cachix.org"
          ];
          "public-keys" = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
        };
      };
    }
  );

  startScript = pkgs.writeShellScript "ncps-start" ''
    mkdir -p ${dataDir}/db
    DATABASE_URL="sqlite:${dataDir}/db/db.sqlite" \
      ${pkgs.ncps}/bin/dbmate-ncps up
    exec ${pkgs.ncps}/bin/ncps --config ${configFile} serve
  '';
in
{
  launchd.daemons.ncps = {
    script = "${startScript}";
    serviceConfig = {
      Label = "org.ncps";
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/ncps.log";
      StandardErrorPath = "/var/log/ncps.log";
    };
  };

  # Prefer local ncps pull-through cache, keep upstreams as fallback so a flaky
  # or down ncps can't wedge builds — nix disables 8501 60s and falls through.
  nix.settings.substituters = lib.mkForce [
    "http://localhost:8501"
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
  ];
  nix.settings.trusted-substituters = lib.mkForce [
    "http://localhost:8501"
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
  ];
  # Keep upstream keys since we're not re-signing narinfos
  nix.settings.trusted-public-keys = lib.mkForce [
    "apollo:Sm6SbXlzRtoqALHOJHeuMubOwemP5i2r6XvbmRbGWTA="

    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
}
