# Canonical Nix binary-cache endpoints — machine-neutral DATA (no `config`, not a
# NixOS module). Each entry pairs a substituter url with its trusted public key so
# the two can never drift apart. Consumers pick a subset via `urls`/`keys`, e.g.
#   let c = import ../data/caches.nix; in c.urls [ "nixos" "hyprland" ]
# This is the single source of truth for cache endpoints across nixos + darwin.
rec {
  caches = {
    nixos = {
      url = "https://cache.nixos.org";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    };
    nix-community = {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
    hyprland = {
      url = "https://hyprland.cachix.org";
      key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
    };
    neovim-nightly = {
      url = "https://neovim-nightly.cachix.org";
      key = "neovim-nightly.cachix.org-1:feIoInHRevVEplgdZvQDjhp11kYASYCE2NGY9hNryx4=";
    };
    nix-gaming = {
      url = "https://nix-gaming.cachix.org";
      key = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
    };
    garnix = {
      url = "https://cache.garnix.io";
      key = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    };
    numtide = {
      url = "https://cache.numtide.com";
      key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    };
  };

  # Select urls / keys for a list of cache names, preserving order.
  urls = names: map (name: caches.${name}.url) names;
  keys = names: map (name: caches.${name}.key) names;
}
