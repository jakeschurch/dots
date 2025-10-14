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
    ./shared
    ./steam.nix
    ./ssh.nix

    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index

    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "nix-bak";
        users.${config.me.username} = { };
        sharedModules = [
          (self + "/configurations/home/${config.me.username}.nix")
          self.homeModules.default
          self.homeModules.linux-only
        ];
      };
    }
    inputs.home-manager.nixosModules.home-manager
  ];
}
