{
  flake,
  ...
}:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{

  imports = [
    {
      home-manager = {
        users.${config.me.username} = { };
        backupFileExtension = "nix-bak";
        sharedModules = [
          self.homeModules.default
          self.homeModules.linux-only
        ];
      };
    }

    ./shared
    ./steam.nix
    ./ssh.nix

    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
  ];
}
