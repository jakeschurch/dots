{ lib, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  system.stateVersion = 6;
}
