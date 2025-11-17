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
      users.users.${config.me.username} = {
        home = "/Users/${config.me.username}";
        shell = pkgs.zsh;
      };

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
    self.nixosModules.common
    inputs.nix-index-database.darwinModules.nix-index

    ./all
    ./homebrew.nix
  ];

}
