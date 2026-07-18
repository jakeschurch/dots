{
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware.nix
    ./cluster.nix
    ./storage.nix
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.vmetal.nixosModules.microvm-host
    inputs.vmetal.nixosModules.k3s-cluster
  ];
}
