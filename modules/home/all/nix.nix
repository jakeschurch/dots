{
  flake,
  pkgs,
  config,
  lib,
  ...
}:
let
  cachesData = import ../../data/caches.nix;
  # home-manager runs on both; scope caches to whichever host we are on.
  cachePlatform = if pkgs.stdenv.hostPlatform.isDarwin then "darwin" else "linux";
in
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
      # Build locally when a substituter is unreachable. With this off, a cache
      # outage (e.g. garnix 503) hard-fails paths nix could trivially build
      # itself, like the firefox-addons .xpi fetchurl FODs.
      fallback = true;

      cores = 0;
      max-jobs = "auto";
      max-substitution-jobs = 40;
      sandbox = "relaxed";
      sandbox-fallback = true;

      substituters = cachesData.defaultUrlsFor cachePlatform;
      trusted-substituters = cachesData.defaultUrlsFor cachePlatform;
      trusted-public-keys = cachesData.defaultKeysFor cachePlatform;

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

      # GitHub API token for flake inputs (avoids 60 req/hr anonymous rate limit).
      # Absolute path: nix.conf itself is a store symlink, so a relative include
      # would resolve inside /nix/store. Leading `!` makes it optional, so
      # machines without the file still work. Contents:
      #   access-tokens = github.com=ghp_...
      !include ${config.xdg.configHome}/nix/access-tokens.conf
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      builders-use-substitutes = true
      extra-nix-path = nixpkgs=flake:nixpkgs

      download-attempts = 3
      http-connections = 0
      require-sigs = false

      ${pkgs.lib.optionalString (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      ''}
      ${pkgs.lib.optionalString (pkgs.stdenv.hostPlatform.system == "x86_64-linux") ''
        # Keep i686 enabled client-side (matches system nix.conf); steam's
        # 32-bit chain (perl IO-Tty etc) needs it on cache misses.
        extra-platforms = i686-linux
      ''}
    '';
  };
}
