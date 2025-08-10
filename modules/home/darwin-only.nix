{ pkgs, flake, ... }:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
    {
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.darwin-only
      ];
      users.users.${config.me.username} = {
        home = "/Users/${config.me.username}";
        isNormalUser = true;
        shell = pkgs.zsh;
      };
      home-manager.users.${config.me.username} = { };
    }
  ];
  home.packages = with pkgs; [
    pngpaste
  ];
}
