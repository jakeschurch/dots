{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  services.displayManager.ly = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.variables.NIXOS_OZONE_WL = "1";

  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.hyprland.nixosModules.default
    ./configuration.nix
    ./disko-config.nix
  ];
}
