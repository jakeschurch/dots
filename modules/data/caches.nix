# Canonical Nix binary-cache endpoints — machine-neutral DATA (no `config`, not a
# NixOS module). Each entry pairs a substituter url with its trusted public key so
# the two can never drift apart. Consumers pick a subset via `urls`/`keys`, e.g.
#   let c = import ../data/caches.nix; in c.urls [ "nixos" "hyprland" ]
# This is the single source of truth for cache endpoints across nixos + darwin.
rec {
  # `platforms` scopes a cache to the systems it actually publishes for. Omit it
  # to mean "everywhere". Listing a cache on a platform it never builds for is
  # harmless but not free: every cache miss pays one extra 404 round-trip.
  caches = {
    nixos = {
      url = "https://cache.nixos.org";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    };
    nix-community = {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
    # Hyprland is a Wayland compositor; it has no darwin build at all.
    hyprland = {
      url = "https://hyprland.cachix.org";
      key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
      platforms = [ "linux" ];
    };
    neovim-nightly = {
      url = "https://neovim-nightly.cachix.org";
      key = "neovim-nightly.cachix.org-1:feIoInHRevVEplgdZvQDjhp11kYASYCE2NGY9hNryx4=";
    };
    # Proton/wine builds — linux only.
    nix-gaming = {
      url = "https://nix-gaming.cachix.org";
      key = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
      platforms = [ "linux" ];
    };
    numtide = {
      url = "https://cache.numtide.com";
      key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    };
  };

  # Select urls / keys for a list of cache names, preserving order.
  urls = names: map (name: caches.${name}.url) names;
  keys = names: map (name: caches.${name}.key) names;

  # The set every machine gets unless it mkForces something narrower (apollo
  # does). Keep this platform-neutral and let `forPlatform` do the scoping —
  # hosts maintaining their own parallel lists is what silently dropped
  # neovim-nightly and numtide from darwin and turned cached packages into
  # local builds.
  default = [
    "nixos"
    "nix-community"
    "hyprland"
    "neovim-nightly"
    "nix-gaming"
    "numtide"
  ];

  # Drop caches that do not publish for `platform` ("linux" | "darwin").
  forPlatform =
    platform: names:
    builtins.filter (name: builtins.elem platform (caches.${name}.platforms or [ platform ])) names;

  defaultFor = platform: forPlatform platform default;
  defaultUrlsFor = platform: urls (defaultFor platform);
  defaultKeysFor = platform: keys (defaultFor platform);
}
