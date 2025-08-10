{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = [
    config.nix.package
  ];

  nix = {
    enable = true;
    package = lib.mkDefault pkgs.nix;

    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "jake"
        "jakeschurch"
      ];

      allowed-users = [ "*" ];
      builders = "@/etc/nix/machines";
      extra-experimental-features = [
        "nix-command flakes pipe-operators auto-allocate-uids ca-derivations git-hashing dynamic-derivations"
      ];
      fallback = false;

      cores = 0;
      max-jobs = "auto";
      max-substitution-jobs = 40;
      sandbox = false;

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      always-allow-substitutes = true;
      auto-allocate-uids = true;
      fsync-metadata = false;
      preallocate-contents = true;

      warn-dirty = false;
      sync-before-registering = true;
      tarball-ttl = 3600 * 5;

      use-xdg-base-directories = true;
    };

    gc.automatic = true;

    extraOptions = ''
      accept-flake-config = true
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      builders-use-substitutes = true
      extra-nix-path = nixpkgs=flake:nixpkgs

      download-attempts = 3
      http-connections = 0
      require-sigs = false

      ${pkgs.lib.optionalString (pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-linux") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      ''}
    '';
  };
}
