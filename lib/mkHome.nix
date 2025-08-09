{
  inputs,
  pkgs,
  system,
  lib,
  stdenv,

  nix-index-database,
  home-manager,
  darwin,
  ...
}:
let

  getSpecialArgs =
    user:
    {
      inherit
        system
        pkgs
        user
        inputs
        ;
    }
    // {
      inherit (pkgs) mkDerivation callPackage stdenv;
    }
    // (import ./default.nix {
      inherit inputs pkgs;
    });

  applyModules =
    user:
    lib.singleton {
      nixpkgs.config = {
        allowUnfree = true;
        cudaSupport = false;
        allowBroken = true;

        allowUnfreePredicate =
          pkg:
          builtins.elem (inputs.nixpkgs.lib.getName pkg) [
            "terraform-1.9.6"
          ];

        permittedInsecurePackages = [
          "electron-19.1.9"
        ];
      };
    }
    ++ lib.singleton (
      {
        home-manager = lib.mkIf stdenv.isDarwin {
          useGlobalPkgs = true;
          useUserPackages = true;
          users."${user}" = import ../home.nix;
          extraSpecialArgs = getSpecialArgs user;
        };

        imports = [
          ../nix.nix
        ]
        ++ lib.optionals stdenv.isDarwin [
          nix-index-database.darwinModules.nix-index
          home-manager.darwinModules.home-manager
          ../modules/homebrew.nix
          ../darwin-configuration.nix
        ]
        ++ lib.optionals stdenv.isLinux [
          ../home.nix
          nix-index-database.hmModules.nix-index
        ];
      }
      // lib.optionalAttrs stdenv.isLinux {
        home = {
          homeDirectory = "/home/${user}";
          username = user;
          enableNixpkgsReleaseCheck = false;
        };
      }
    );

  applyConfig =
    user:
    {
      modules = applyModules user;
    }
    // lib.optionalAttrs stdenv.isLinux {
      extraSpecialArgs = getSpecialArgs user;
    }
    // lib.optionalAttrs stdenv.isDarwin {
      inherit system;
      specialArgs = getSpecialArgs user;
    };

  mkHome =
    user:
    if stdenv.isLinux then
      let
        userConfig = applyConfig user;
      in
      home-manager.lib.homeManagerConfiguration { inherit userConfig; }
    else
      (darwin.lib.darwinSystem (applyConfig user)).config.system.build.toplevel;
in
mkHome
