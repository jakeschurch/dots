{ pkgs, flake, ... }:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    {
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.darwin-only
      ];
      users.users.${config.me.username} = {
        home = "/Users/${config.me.username}";
      };
      home-manager.users.${config.me.username} = { };
    }
    inputs.nix-index-database.darwinModules.nix-index
  ];
  home.packages = with pkgs; [
    pngpaste
  ];
}
