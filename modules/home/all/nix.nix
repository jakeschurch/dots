{
  flake,
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

    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry = {
      nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    };

    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "jake"
        "jakeschurch"
      ];

      allowed-users = [ "*" ];
      # builders = "@/etc/nix/machines";
      extra-experimental-features = [
        "nix-command flakes auto-allocate-uids"
      ];
      fallback = false;

      cores = 0;
      max-jobs = "auto";
      max-substitution-jobs = 40;
      sandbox = "relaxed";
      sandbox-fallback = true;

      substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

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
