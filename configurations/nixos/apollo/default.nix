{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.common
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
}
