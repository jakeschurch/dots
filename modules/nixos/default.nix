{
  flake,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (flake) inputs;
  flakeConfig = flake.config;
  inherit (inputs) self;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager

    {
      programs.fish.enable = true;

      users.users.${flakeConfig.me.username}.shell = pkgs.fish;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "nix-bak";
        users.${flakeConfig.me.username} = { };
        sharedModules = [
          (self + "/configurations/home/${flakeConfig.me.username}.nix")
          self.homeModules.default
          self.homeModules.linux-only
        ];
      };
    }

    ./shared
    ./docker.nix
    ./printing.nix
    ./steam.nix
    ./ssh.nix
    # ./ollama-intel.nix

    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = lib.optionals config.profiles.desktop.enable (
    with pkgs;
    [
      google-chrome
      pcmanfm
    ]
  );

  programs.nix-ld.enable = true;
  virtualisation.libvirtd = {
    enable = true;
  };
}
