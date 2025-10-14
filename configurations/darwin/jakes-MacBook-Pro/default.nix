{ lib, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
  ];

  system.primaryUser = "jake";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
