{ flake, pkgs, ... }:

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
    withUWSM = true;

    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  environment.variables.NIXOS_OZONE_WL = "1";

  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./disko-config.nix
  ];
}
