{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    self.nixosModules.common
    inputs.disko.nixosModules.disko
    ./disko-config.nix
  ];
}
