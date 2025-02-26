{
  pkgs,
  inputs,
  ...
}:
let
  specialArgs = {
    inherit inputs;
    inherit pkgs;
    inherit (pkgs) system;
  } // inputs;

  mkDarwinHome =
    user:
    inputs.darwin.lib.darwinSystem {
      inherit (pkgs) system;

      specialArgs = specialArgs // {
        inherit inputs;
        inherit (pkgs) lib;
      };
      modules = [
        { _module.args = specialArgs; }
        inputs.nix-index-database.darwinModules.nix-index
        (import ../darwin-configuration.nix { inherit pkgs user; })
        ../modules/homebrew.nix
        inputs.home-manager.darwinModules.home-manager
        ../nix.nix
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${user}" = import ../home.nix;
          };
        }
      ];
    };

  mkHmHome =
    user:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ../nix.nix
        ../home.nix
        inputs.nix-index-database.hmModules.nix-index
        (_: {
          environment.pathsToLink = [ "/share/zsh" ];

          home = {
            homeDirectory = "/home/${user}";
            username = user;
            enableNixpkgsReleaseCheck = false;
          };
        })
      ];

      extraSpecialArgs = specialArgs // {
        inherit user;
      };
    };

  mkHome = user: if pkgs.stdenv.isLinux then mkHmHome user else mkDarwinHome user;
in
mkHome
