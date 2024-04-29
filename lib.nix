{
  lib,
  darwin,
  system,
  pkgs,
  home-manager,
  inputs,
}: {
  mkDarwinHome = {user}:
    darwin.lib.darwinSystem {
      inherit system pkgs;

      modules = [
        inputs.nix-index-database.darwinModules.nix-index
        ({lib, ...}: {
          nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
        })

        (import ./darwin-configuration.nix {inherit pkgs user;})
        ./modules/homebrew.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${user}" = import ./home.nix;
          };
        }
      ];

      specialArgs = {
        inherit inputs system pkgs user;
        inherit (pkgs) lib;
      };
    };

  mkHmHome = {user}:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./home.nix
        inputs.nix-index-database.hmModules.nix-index
        ({lib, ...}: {
          nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
          nix.package = pkgs.nixFlakes;
          environment.pathsToLink = ["/share/zsh"];

          home = {
            homeDirectory = "/home/${user}";
            username = user;
          };
        })
      ];
    };
}
