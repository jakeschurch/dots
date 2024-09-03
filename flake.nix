{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.flake = true;

    tfenv.url = "github:cjlarose/tfenv-nix";
    unstable.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixGL = {
      url = "github:guibou/nixGL";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lexical-lsp.url = "github:lexical-lsp/lexical";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    experimental-features = "nix-command flakes";
    warn-dirty = false;
    sandbox = true;
    extra-sandbox-paths = ["/nix/var/cache/ccache"];
    keep-derivations = false;
    pure-eval = false;
    extra-trusted-substituters = [
      "s3://nix-cache?profile=default&scheme=https&endpoint=s3.jakeschurch.com&trusted=1"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
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
    treefmt-nix,
    nix-pre-commit-hooks,
    flake-utils,
    unstable,
    home-manager,
    darwin,
    nixGL,
    lexical-lsp,
    nixd,
    tfenv,
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
      system: let
        inherit (inputs.unstable.lib) optionalAttrs;

        pkgs = import nixpkgs {
          inherit system;

          config = {
            allowUnfree = true;
            # replaceStdenv = {pkgs}: pkgs.ccacheStdenv;

            permittedInsecurePackages = [
              "electron-19.1.9"
            ];
            packageOverrides = _pkgs: {
              inherit lexical-lsp;
              inherit (nixpkgs) narHash;
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
              nixd.overlays.default
              nixGL.overlay
              tfenv.overlays.default
            ]
            ++ import ./overlays.nix {pkgs = import nixpkgs {inherit system;};};
        };

        treefmtEval = pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        pre-commit-check = import ./pre-commit-hooks.nix {
          inherit pkgs system nix-pre-commit-hooks;
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
