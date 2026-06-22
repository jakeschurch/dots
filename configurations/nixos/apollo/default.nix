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
    ./boot.nix
    ./storage.nix
    ./cluster.nix
    ./hyprland.nix
    ./greetd.nix
    ./vial.nix
    (self + "/modules/nixos/tablet.nix")
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.hyprland.nixosModules.default
    inputs.xremap-flake.nixosModules.default
    inputs.vmetal.nixosModules.microvm-host
    inputs.vmetal.nixosModules.k3s-cluster
  ];
}
