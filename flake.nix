{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    tfenv.url = "github:cjlarose/tfenv-nix";

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

    disko = {
      url = "github:nix-community/disko/latest";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lexical-lsp.url = "github:lexical-lsp/lexical";
    lexical-lsp.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    mcp-hub.url = "github:ravitemer/mcp-hub";
    mcp-hub.inputs.nixpkgs.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";
  };

  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
    };

  # outputs =
  #   inputs:
  #   inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  #     systems = [
  #       "x86_64-linux"
  #       "aarch64-linux"
  #       "aarch64-darwin"
  #       "x86_64-darwin"
  #     ];

  #     perSystem =
  #       {
  #         pkgs,
  #         lib,
  #         system,
  #         ...
  #       }:
  #       let
  #         mkHome = import ./lib/mkHome.nix {
  #           inherit
  #             inputs
  #             system
  #             lib
  #             pkgs
  #             ;
  #           inherit (pkgs) stdenv;
  #           inherit (inputs) nix-index-database home-manager darwin;
  #         };
  #       in
  #       {
  #         _module.args.pkgs = import inputs.nixpkgs {
  #           inherit system;
  #           overlays = import ./overlays.nix { inherit inputs; };

  #           config.allowUnfree = true;
  #         };

  #         packages = rec {
  #           jake = mkHome "jake";
  #           droid = mkHome "droid"; # for pixel phone

  #           default = jake;
  #         };
  #       };
  #   };

  nixConfig = {
    download-attempts = 3;
    http-connections = 0;

    builders = [ ];

    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "auto-allocate-uids"
      "pipe-operators"
      "dynamic-derivations"
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
