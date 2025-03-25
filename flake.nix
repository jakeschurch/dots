{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "nixpkgs/nixos-24.11";

    unstable.url = "nixpkgs/nixos-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "unstable";

    tfenv.url = "github:cjlarose/tfenv-nix";

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
      "pipe-operators"
      "dynamic-derivations"
    ];

    cores = 0;
    max-jobs = "auto";
    builders-use-substitutes = true;
    substitute = true;
    sandbox = false;
    fsync-metadata = false;

    auto-allocate-uids = true;
    preallocate-contents = true;

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
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      pkgsFor =
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
            builtins.elem (nixpkgs.lib.getName pkg) [
              "terraform-1.9.6"
            ];

          permittedInsecurePackages = [
            "electron-19.1.9"
          ];

          overlays = import ./overlays.nix { inherit inputs; };
        };

      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = pkgsFor system; });
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:

        let
          getDrvActivationPackage =
            drv: if pkgs.stdenv.isLinux then drv.activationPackage else drv.config.system.build.toplevel;

          drvs = rec {
            jake = pkgs.lib.mkHome "jake";
            droid = pkgs.lib.mkHome "droid"; # for pixel phone

            default = jake;
          };
        in
        pkgs.lib.mapAttrs (_: getDrvActivationPackage) drvs
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
          };
        }
      );

      formatter = forEachSupportedSystem (
        { pkgs }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        treefmtEval.config.build.wrapper
      );

      checks = forEachSupportedSystem (
        { pkgs }:
        {
          pre-commit-check = import ./pre-commit-hooks.nix {
            inherit pkgs;
            inherit (inputs) nix-pre-commit-hooks;
          };
        }
      );
    };
}
