{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./disko-config.nix
  ];
}
