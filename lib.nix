{
  lib,
  darwin,
  nixpkgs,
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

        ./darwin-configuration.nix
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
        inherit nixpkgs;
      };
    };

  mkHmHome = {user}:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./home.nix
        inputs.nix-index-database.hmModules.nix-index
        (_: {
          environment.pathsToLink = ["/share/zsh"];

          home = {
            homeDirectory = "/home/${user}";
            username = user;
          };
        })
      ];
    };
}
