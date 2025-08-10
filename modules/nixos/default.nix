{ flake, lib, ... }:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
    {
      users.users.${config.me.username}.isNormalUser = lib.mkDefault true;
      home-manager.users.${config.me.username} = { };
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.linux-only
      ];
    }
  ];
}
