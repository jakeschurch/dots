{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager

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

    ./shared
    ./steam.nix
    ./ssh.nix

    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
  ];

  environment.systemPackages = with pkgs; [
    google-chrome
  ];
}
