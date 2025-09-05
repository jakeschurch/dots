{
  flake,
  config,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      users.users.${config.me.username}.isNormalUser = lib.mkDefault true;
      home-manager = {
        users.${config.me.username} = { };
        sharedModules = [
          self.homeModules.default
          self.homeModules.linux-only
        ];
      };
    }
    ./steam.nix
    ./ssh.nix

    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
    ./shared
  ];

  boot.loader.grub.configurationLimit = 2;
}
