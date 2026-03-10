{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    {
      users.knownUsers = [ config.me.username ];

      users.users.${config.me.username} = {
        uid = 501;
        home = "/Users/${config.me.username}";
        shell = pkgs.fish;
      };

      programs.fish.enable = true;

      nixpkgs = {
        overlays = lib.attrValues self.overlays;
        config.allowUnfree = true;
      };

      home-manager = {
        backupFileExtension = "nix-bak";
        users.${config.me.username} = { };
        sharedModules = [
          (self + "/configurations/home/${config.me.username}.nix")
          self.homeModules.default
          self.homeModules.darwin
        ];
      };
    }
    inputs.nix-index-database.darwinModules.nix-index

    ./all
    ./homebrew.nix
  ];

}
