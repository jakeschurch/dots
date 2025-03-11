{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "nixpkgs/nixos-24.11";

    unstable.url = "nixpkgs/nixos-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tfenv.url = "github:cjlarose/tfenv-nix";

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixGL = {
      url = "github:guibou/nixGL";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lexical-lsp.url = "github:lexical-lsp/lexical";
    lexical-lsp.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    nix-pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    download-attempts = 3;
    http-connections = 0;

    max-substitution-jobs = 0;

    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "auto-allocate-uids"
    ];

    cores = 0;
    max-jobs = "auto";
    pure-eval = true;
    builders-use-substitutes = true;
    substitute = true;
    sandbox = false;
    fsync-metadata = false;

    auto-allocate-uids = true;
    preallocate-contents = true;

    substituters = [
      "https://cache.lix.systems?priority=1"
      "https://nix-community.cachix.org?priority=2"
      "https://cache.nixos.org?priority=3"
    ];

    trusted-substituters = [
      "https://cache.lix.systems?priority=1"
      "https://nix-community.cachix.org?priority=2"
      "https://cache.nixos.org?priority=3"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    warn-dirty = false;

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

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      with nixpkgs.lib;
      let
        basePkgs =
          system:
          import nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
              cudaSupport = false;
              allowBroken = true;
            };

            allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "terraform-1.9.6"
              ];

            permittedInsecurePackages = [
              "electron-19.1.9"
            ];

            packageOverrides = _pkgs: {
              inherit (inputs) lexical-lsp;
              inherit (nixpkgs) narHash;

              terragrunt = _pkgs.terragrunt.overrideAttrs (_oldAttrs: {
                version = "0.69.1";
              });
            };

            overlays = import ./overlays.nix {
              inherit inputs system;
            };
          };

        treefmtEval = pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        pre-commit-check =
          pkgs:
          import ./pre-commit-hooks.nix {
            inherit pkgs system;
            inherit (inputs) nix-pre-commit-hooks;
          };

        pkgs = basePkgs system;
      in
      rec {
        inherit (pkgs.lib) mkHome;

        darwinConfigurations.curiosity = mkHome "jake";
        homeConfigurations.apollo = mkHome "jake";

        packages.default =
          if pkgs.stdenv.isLinux then
            homeConfigurations.apollo.activationPackage
          else
            darwinConfigurations.curiosity.config.system.build.toplevel;

        devShells.default =
          let
            pre-commitEval = self.checks.${system}.pre-commit-check pkgs;
          in
          pkgs.mkShell {
            inherit (pre-commitEval) shellHook;
          };

        formatter = (treefmtEval pkgs).config.build.wrapper;

        checks = {
          inherit pre-commit-check;
        };

        apps = { };
      }
    );
}
