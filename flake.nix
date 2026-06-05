{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    blink-pairs.url = "github:saghen/blink.pairs";
    blink-pairs.inputs.nixpkgs.follows = "nixpkgs";

    nixGL = {
      url = "github:guibou/nixGL";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    mcp-hub.url = "github:ravitemer/mcp-hub";
    mcp-hub.inputs.nixpkgs.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";
    flake-parts.url = "github:hercules-ci/flake-parts";

    hyprland.url = "github:hyprwm/Hyprland/refs/tags/v0.55.2";
    # hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    phonto = {
      url = "github:museslabs/phonto";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    expert.url = "github:elixir-lang/expert";

    vmetal.url = "github:jakeschurch/homelab/v1?dir=vmetal";
    vmetal.inputs.nixpkgs.follows = "nixpkgs";
    vmetal.inputs.sops-nix.follows = "sops-nix";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
    };

  nixConfig = {
    download-attempts = 3;
    http-connections = 25;
    download-buffer-size = 904857600; # 900 MiB
    fallback = true;

    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    sandbox = "relaxed";
    sandbox-fallback = true;
    cores = 0;
    max-jobs = "auto";
    max-substitution-jobs = 16;

    builders = [ ];

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
      "auto-allocate-uids"
    ];

    allowed-impure-host-deps = [
      "/usr/bin/ditto" # for darwin builds
      "/bin/sh"
      "/usr/lib/libSystem.B.dylib"
      "/usr/lib/system/libunc.dylib"
      "/dev/zero"
      "/dev/random"
      "/dev/urandom"
    ];
  };
}
