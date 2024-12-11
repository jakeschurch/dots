{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "nixpkgs/nixos-24.11";

    unstable.url = "nixpkgs/nixpkgs-unstable";

    tfenv.url = "github:cjlarose/tfenv-nix";

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
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

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "unstable";
  };

  nixConfig = {
    experimental-features = "nix-command flakes pipe-operators";
    warn-dirty = false;
    sandbox = false;
    extra-sandbox-paths = ["/nix/var/cache/ccache"];
    keep-derivations = false;
    pure-eval = false;
    keep-outputs = false;
    keep-going = false;
    keep-failed = false;
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

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    unstable,
    ...
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
    ];
  in
    flake-utils.lib.eachSystem supportedSystems
    (
      system:
        with nixpkgs.lib; let
          pkgs = import inputs.nixpkgs {
            inherit system;

            config = {
              allowUnfree = true;
              # replaceStdenv = {pkgs}: pkgs.ccacheStdenv;

              allowUnfreePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "terraform-1.9.6"
                ];

              permittedInsecurePackages = [
                "electron-19.1.9"
              ];
              packageOverrides = _pkgs: {
                inherit (inputs) lexical-lsp;
                inherit (nixpkgs) narHash;

                neovim = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

                unstable = import unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              };
            };

            overlays =
              nixpkgs.lib.singleton (
                _final: prev: {
                  lib =
                    prev.lib
                    // import ./lib.nix {
                      inherit nixpkgs;
                      inherit (nixpkgs) lib;
                      inherit system pkgs home-manager darwin inputs;
                    };
                }
              )
              ++ nixpkgs.lib.singleton (
                final: prev: {
                  # Add access to x86 packages system is running Apple Silicon
                  apple-silicon = optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
                    pkgs-x86 = import inputs.unstable {
                      system = "x86_64-darwin";
                      inherit (pkgs) config;
                    };
                  };

                  pkgs-x86 = optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
                    inherit
                      (final.pkgs-x86)
                      julia_18-bin
                      ;
                  };

                  cython = prev.python3Packages.cython.overrideAttrs (prevAttrs: {
                    patches = prevAttrs.patches ++ [./patches/disable_spawn.patch];
                  });
                }
              )
              ++ [
                inputs.nixd.overlays.default
                inputs.nixGL.overlay
                inputs.tfenv.overlays.default
              ]
              ++ import ./overlays.nix {pkgs = import nixpkgs {inherit system;};};
          };

          treefmtEval = pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          pre-commit-check = import ./pre-commit-hooks.nix {
            inherit pkgs system;
            inherit (inputs) nix-pre-commit-hooks;
          };
        in rec {
          darwinConfigurations.curiosity = pkgs.lib.mkDarwinHome {user = "jake";};
          homeConfigurations.apollo = pkgs.lib.mkHmHome {user = "jake";};

          packages.default =
            if pkgs.stdenv.isLinux
            then homeConfigurations.apollo.activationPackage
            else
              darwinConfigurations
              .curiosity
              .config
              .system
              .build
              .toplevel;

          devShells.default = pkgs.mkShell {
            shellHook = ''
              ${self.checks.${system}.pre-commit-check.shellHook}
            '';
          };

          formatter = (treefmtEval pkgs).config.build.wrapper;

          checks = {
            inherit pre-commit-check;
          };

          apps = {};
        }
    );
}
