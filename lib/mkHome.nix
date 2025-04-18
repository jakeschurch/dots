{
  pkgs,
  inputs,
  ...
}:
with pkgs;
with inputs;
let
  getSpecialArgs =
    user:
    {
      inherit
        inputs
        pkgs
        system
        lib
        user
        ;
    }
    // inputs;

  applyModules =
    user:
    lib.singleton (
      {
        home-manager = lib.mkIf stdenv.isDarwin {
          useGlobalPkgs = true;
          useUserPackages = true;
          users."${user}" = import ../home.nix;
        };

        imports =
          [
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
      inherit pkgs;
      extraSpecialArgs = getSpecialArgs user;
    }
    // lib.optionalAttrs stdenv.isDarwin {
      inherit system;
      specialArgs = getSpecialArgs user;
    };

  mkHome =
    user:
    if stdenv.isLinux then
      home-manager.lib.homeManagerConfiguration
    else
      darwin.lib.darwinSystem (applyConfig user);
in
mkHome
