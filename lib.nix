{
  lib,
  system,
  pkgs,
  inputs,
}:
with inputs; let
  specialArgs = {
    inherit inputs system pkgs;
    inherit (pkgs) lib;
    self = builtins.getFlake (toString ./.);
  };
in {
  mkDarwinHome = {user}:
    darwin.lib.darwinSystem {
      inherit system pkgs;

      modules = [
        {_module.args = specialArgs;}
        inputs.nix-index-database.darwinModules.nix-index
        ./darwin-configuration.nix
        ./modules/homebrew.nix
        ./nix.nix
        inputs.determinate.darwinModules.default

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${user}" = import ./home.nix;
          };
        }
      ];

      specialArgs = specialArgs // {inherit user;};
    };

  mkHmHome = {user}:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./nix.nix
        ./home.nix
        inputs.determinate.homeModules.default
        inputs.nix-index-database.hmModules.nix-index
        (_: {
          environment.pathsToLink = ["/share/zsh"];

          home = {
            homeDirectory = "/home/${user}";
            username = user;
            enableNixpkgsReleaseCheck = false;
          };
        })
      ];

      extraSpecialArgs = specialArgs // {inherit user;};
    };
}
