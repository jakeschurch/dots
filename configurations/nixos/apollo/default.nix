{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
